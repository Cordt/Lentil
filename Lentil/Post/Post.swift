// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Post: Reducer {
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
    enum CommentsResponse: Equatable {
      case upsert(_ publications: [Model.Publication])
      case delete(_ publicationIds: [Model.Publication.ID])
    }
    
    case didAppear
    case dismissView
    case fetchComments
    case observeCommentsUpdates
    case cancelObserveCommentsUpdates
    case commentsResponse(TaskResult<CommentsResponse>)
    
    case post(action: Publication.Action)
    case comment(id: String, action: Post.Action)
    
    case postTapped
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.navigate) var navigate
  @Dependency(\.uuid) var uuid
  
  enum CancelID { case observeComments }
  
  var body: some Reducer<State, Action> {
    Scope(state: \.post, action: /Action.post) {
      Publication()
    }
    
    Reduce { state, action in
      switch action {
        case .didAppear:
          return .send(.observeCommentsUpdates)
          
        case .dismissView:
          return .run { send in
            await send(.cancelObserveCommentsUpdates)
            await self.dismiss()
          }
          
          
        case .fetchComments:
          return .run { [publication = state.post.publication] send in
            await send(.commentsResponse(
              TaskResult {
                let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
                let comments = try await self.cache.comments(publication, userProfile?.id)
                return .upsert(comments)
              }
            )
            )
          }
          
        case .observeCommentsUpdates:
          state.commentsObserver = self.cache.commentsObserver(state.post.id)
          return .run { [events = state.commentsObserver?.events] send in
            guard let events else { return }
            for try await event in events {
              switch event {
                case .initial(let publications), .update(let publications):
                  await send(.commentsResponse(.success(.upsert(publications))))
                  
                case .delete(let deletionKeys):
                  await send(.commentsResponse(.success(.delete(deletionKeys))))
              }
            }
          }
          .cancellable(id: CancelID.observeComments, cancelInFlight: true)
          
        case .cancelObserveCommentsUpdates:
          return .cancel(id: CancelID.observeComments)
          
        case .commentsResponse(let response):
          switch response {
            case .success(let result):
              switch result {
                case .upsert(let publications):
                  publications.forEach {
                    state.comments.updateOrAppend(
                      Post.State(navigationId: self.uuid.callAsFunction().uuidString, post: Publication.State(publication: $0), typename: .comment)
                    )
                  }
                case .delete(let publicationIds):
                  publicationIds.forEach {
                    state.comments.remove(id: $0)
                  }
              }
              return .none
              
            case .failure(let error):
              log("Could not fetch publications from Cache", level: .warn, error: error)
              return .none
          }
          
        case .post, .comment:
          return .none
         
        case .postTapped:
          self.navigate.navigate(.publication(state.post.id))
          return .none
      }
    }
    .forEach(\.comments, action: /Action.comment) {
      Post()
    }
  }
}
