// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import SwiftUI


struct Profile: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var navigationId: String
    var id: String { self.navigationId }
    
    var profile: Model.Profile
    var posts: IdentifiedArrayOf<Post.State>
    var cursorPublications: String?
    
    var remoteCoverPicture: LentilImage.State?
    var remoteProfilePicture: LentilImage.State?
    
    init(navigationId: String, profile: Model.Profile) {
      self.navigationId = navigationId
      self.profile = profile
      self.posts = []
      self.cursorPublications = nil
      self.remoteCoverPicture = nil
      self.remoteProfilePicture = nil
      
      if let coverPictureUrl = profile.coverPictureUrl {
        self.remoteCoverPicture = .init(imageUrl: coverPictureUrl, kind: .cover)
      }
      if let profilePictureUrl = profile.profilePictureUrl {
        self.remoteProfilePicture = .init(imageUrl: profilePictureUrl, kind: .profile(profile.handle))
      }
    }
  }
  
  indirect enum Action: Equatable {
    case dismissView
    case loadProfile
    case remoteCoverPicture(LentilImage.Action)
    case remoteProfilePicture(LentilImage.Action)
    case fetchPublications
    case publicationsResponse(TaskResult<[Model.Publication]>)
    
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .dismissView:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.id,
              destination: .profile(state.profile.id)
            )
          )
          return .none
          
        case .loadProfile:
          return Effect(value: .fetchPublications)
          
        case .fetchPublications:
          return .task { [id = state.profile.id] in
            await .publicationsResponse(
              TaskResult {
                try await lensApi.publications(40, nil, id, [.post], .fetchIgnoringCacheData, id).data
              }
            )
          }
          
        case .publicationsResponse(.success(let publications)):
          publications
            .filter { $0.typename == .post }
            .map { publication in
              if var postState = state.posts.first(where: { $0.post.publication.id == publication.id }) {
                postState.post.publication = publication
                return postState
              }
              else {
                return Post.State(
                  navigationId: uuid.callAsFunction().uuidString,
                  post: .init(publication: publication),
                  typename: Post.State.Typename.from(typename: publication.typename)
                )
              }
            }
            .forEach { state.posts.updateOrAppend($0) }
          
          state.posts.sort { $0.post.publication.createdAt > $1.post.publication.createdAt }
          
          publications
            .filter { $0.typename == .post }
            .forEach { Cache.shared.updateOrAppend($0) }
          
          publications
            .forEach { Cache.shared.updateOrAppend($0.profile) }
          
          return .none
          
        case .publicationsResponse(.failure(let error)):
          log("Failed to load publications for profile", level: .error, error: error)
          return .none
          
        case .remoteCoverPicture, .remoteProfilePicture:
          return .none
          
        case .post:
          return .none
      }
    }
    .ifLet(\.remoteCoverPicture, action: /Action.remoteCoverPicture) {
      LentilImage()
    }
    .ifLet(\.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      LentilImage()
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
