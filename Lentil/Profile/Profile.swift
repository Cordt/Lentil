// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Profile: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var navigationId: String
    var id: String { self.navigationId }
    
    var profile: Model.Profile
    var posts: IdentifiedArrayOf<Post.State> = []
    var cursorPublications: String?
    
    var coverPicture: Image?
    var remoteCoverPicture: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.profile.coverPictureUrl,
          image: self.coverPicture
        )
      }
      set {
        self.coverPicture = newValue.image
      }
    }
    var profilePicture: Image?
    var remoteProfilePicture: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.profile.profilePictureUrl,
          image: self.profilePicture
        )
      }
      set {
        self.profilePicture = newValue.image
      }
    }
  }
  
  indirect enum Action: Equatable {
    case dismissView
    case loadProfile
    case remoteCoverPicture(RemoteImage.Action)
    case remoteProfilePicture(RemoteImage.Action)
    case fetchPublications
    case publicationsResponse(TaskResult<[Model.Publication]>)
    
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.remoteCoverPicture, action: /Action.remoteCoverPicture) {
      RemoteImage()
    }
    Scope(state: \.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      RemoteImage()
    }
    
    Reduce { state, action in
      switch action {
        case .dismissView:
          self.navigationApi.remove(DestinationPath(navigationId: state.id, elementId: state.profile.id))
          return .none
          
        case .loadProfile:
          return .merge(
            Effect(value: .remoteProfilePicture(.fetchImage)),
            Effect(value: .remoteCoverPicture(.fetchImage)),
            Effect(value: .fetchPublications)
          )
          
        case .fetchPublications:
          return .task { [id = state.profile.id] in
            await .publicationsResponse(
              TaskResult {
                try await lensApi.publications(40, nil, id, [.post], id).data
              }
            )
          }
          
        case .publicationsResponse(.success(let publications)):
          publications
            .filter { $0.typename == .post }
            .map { Post.State(navigationId: uuid.callAsFunction().uuidString, post: .init(publication: $0)) }
            .forEach { state.posts.updateOrAppend($0) }
          
          state.posts.sort { $0.post.publication.createdAt > $1.post.publication.createdAt }
          
          publications
            .filter { $0.typename == .post }
            .forEach { publicationsCache.updateOrAppend($0) }
          
          publications
            .forEach { profilesCache.updateOrAppend($0.profile) }
          
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
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
