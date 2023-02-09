// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import SwiftUI


struct Profile: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: String { self.profile.id }
    var navigationId: String
    
    var profile: Model.Profile
    var posts: IdentifiedArrayOf<Post.State>
    var cursorPublications: String?
    
    var twitterURL: URL? {
      guard let twitterAttribute = self.profile.attributes.first(where: { $0.key == .twitter })
      else { return nil }
      return URL(string: "https://twitter.com/" + twitterAttribute.value)
    }
    
    var websiteURL: URL? {
      guard let websiteAttribute = self.profile.attributes.first(where: { $0.key == .website })
      else { return nil }
      return URL(string: websiteAttribute.value)
    }
    
    var profileLocation: String? {
      guard let locationAttribute = self.profile.attributes.first(where: { $0.key == .location })
      else { return nil }
      return locationAttribute.value
    }
    
    var coverOffset: CGFloat = 0.0
    var profileDetailHidden: Bool {
      self.coverOffset <= -100
    }
    
    init(navigationId: String, profile: Model.Profile) {
      self.navigationId = navigationId
      self.profile = profile
      self.posts = []
      self.cursorPublications = nil
    }
  }
  
  indirect enum Action: Equatable {
    case dismissView
    case didAppear
    case fetchPublications
    case publicationsResponse(TaskResult<[Model.Publication]>)
    case scrollPositionChanged(CGPoint)
    
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .dismissView:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.navigationId,
              destination: .profile(state.profile.id)
            )
          )
          return .none
          
        case .didAppear:
          return .send(.fetchPublications)
          
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
            .forEach { self.cache.updateOrAppendPublication($0) }
          
          publications
            .forEach { self.cache.updateOrAppendProfile($0.profile) }
          
          return .none
          
        case .publicationsResponse(.failure(let error)):
          log("Failed to load publications for profile", level: .error, error: error)
          return .none
          
        case .scrollPositionChanged(let position):
          state.coverOffset = min(max(position.y, -200), 0)
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
