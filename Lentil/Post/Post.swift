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
    
    var commentsObserver: CollectionObserver<Model.Publication>? = nil
  }
  
  indirect enum Action: Equatable {
    case didAppear
    case dismissView
    case fetchComments
    case observeCommentsUpdates
    case commentsResponse(TaskResult<[Model.Publication]>)
    
    case post(action: Publication.Action)
    case comment(id: String, action: Post.Action)
    
    case postTapped
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  enum CancelObserveCommentsID {}
  
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
          return .cancel(id: CancelObserveCommentsID.self)
          
        case .fetchComments:
          return .task { [publication = state.post.publication] in
            await .commentsResponse(
              TaskResult {
                let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
                return try await self.cache.comments(publication, userProfile?.id)
              }
            )
          }
          
        case .observeCommentsUpdates:
          state.commentsObserver = self.cache.commentsObserver(state.post.id)
          return .run { [events = state.commentsObserver?.events] send in
            guard let events else { return }
            for try await event in events {
              switch event {
                case .initial(let publications):
                  await send(.commentsResponse(.success(publications)))
                case .update(let publications, deletions: _, insertions: _, modifications: _):
                  await send(.commentsResponse(.success(publications)))
              }
            }
          }
          .cancellable(id: CancelObserveCommentsID.self, cancelInFlight: true)
          
        case .commentsResponse(let response):
          switch response {
            case .success(let result):
              result.forEach {
                state.comments.updateOrAppend(
                  Post.State(navigationId: self.uuid.callAsFunction().uuidString, post: Publication.State(publication: $0), typename: .comment)
                )
              }
              return .none
              
            case .failure(let error):
              log("Could not fetch publications from Cache", level: .warn, error: error)
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
