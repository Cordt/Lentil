// Lentil

import ComposableArchitecture
import SwiftUI


struct Post: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var post: Publication.State
    var comments: IdentifiedArrayOf<Comment.State> = []
    
    var id: String { self.post.id }
  }
  
  enum Action: Equatable {
    case fetchReactions
    case reactionsResponse(TaskResult<QueryResult<Model.Publication>>)
    case fetchComments
    case commentsResponse(TaskResult<QueryResult<[Model.Publication]>>)
    
    case post(action: Publication.Action)
    case comment(id: Comment.State.ID, action: Comment.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .fetchReactions:
        return .task { [publication = state.post.publication] in
          await .reactionsResponse(
            TaskResult {
              try await lensApi.reactionsOfPublication(publication)
            }
          )
        }
        
      case .reactionsResponse(let response):
        switch response {
          case .success(let result):
            state.post.publication = result.data
            return .none
            
          case .failure(let error):
            print("[WARN] Could not fetch publications from API: \(error)")
            return .none
        }
        
      case .fetchComments:
        return .task { [publication = state.post.publication] in
          await .commentsResponse(
            TaskResult {
              try await lensApi.commentsOfPublication(publication)
            }
          )
        }
        
      case .commentsResponse(let response):
        switch response {
          case .success(let result):
            state.comments.append(
              contentsOf: result.data.map {
                Comment.State(comment: Publication.State(publication: $0))
              }
            )
            return .none
            
          case .failure(let error):
            print("[WARN] Could not fetch publications from API: \(error)")
            return .none
        }
        
        
      case .post(_):
        return .none
        
      case .comment(_, _):
        return .none
    }
  }
}
