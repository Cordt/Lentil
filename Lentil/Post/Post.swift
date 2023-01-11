// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Post: ReducerProtocol {
  struct State: Equatable, Identifiable {
    enum Typename: Equatable {
      case post
      case comment
      case mirror
      
      static func from(typename: Model.Publication.Typename) -> Self {
        switch typename {
          case .post:     return .post
          case .comment:  return .comment
          case .mirror:   return .mirror
        }
      }
    }
    
    var id: String { self.post.id }
    var navigationId: String
    var post: Publication.State
    var typename: Typename
    var comments: IdentifiedArrayOf<Post.State> = []
    
    var commenter: String? {
      self.comments.first?.post.publication.profile.name ?? self.comments.first?.post.publication.profile.handle
    }
    var mirrorer: String? {
      guard case let .mirror(mirroringProfile) = self.post.publication.typename
      else { return nil }
      return mirroringProfile.name ?? mirroringProfile.handle
    }
    
  }
  
  indirect enum Action: Equatable {
    case didAppear
    case dismissView
    case fetchComments
    case commentsResponse(TaskResult<PaginatedResult<[Model.Publication]>>)
    
    case post(action: Publication.Action)
    case comment(id: String, action: Post.Action)
    
    case postTapped
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.post, action: /Action.post) {
      Publication()
    }
    
    Reduce { state, action in
      switch action {
        case .didAppear:
          return .none
          
        case .dismissView:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.navigationId,
              destination: .publication(state.post.id)
            )
          )
          return .none
          
        case .fetchComments:
          return .task { [publication = state.post.publication] in
            await .commentsResponse(
              TaskResult {
                let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
                return try await lensApi.commentsOfPublication(publication, userProfile?.id)
              }
            )
          }
          
        case .commentsResponse(let response):
          switch response {
            case .success(let result):
              state.comments.append(
                contentsOf: result.data.map {
                  Post.State(navigationId: self.uuid.callAsFunction().uuidString, post: Publication.State(publication: $0), typename: .comment)
                }
              )
              
              result.data
                .forEach { self.cache.updateOrAppendPublication($0) }
              
              return .none
              
            case .failure(let error):
              log("Could not fetch publications from API", level: .warn, error: error)
              return .none
          }
          
        case .post, .comment:
          return .none
         
        case .postTapped:
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .publication(state.post.id)
            )
          )
          return .none
      }
    }
    .forEach(\.comments, action: /Action.comment) {
      Post()
    }
  }
}
