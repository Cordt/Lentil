// Lentil

import ComposableArchitecture
import SwiftUI


struct PostState: Equatable, Identifiable {
  var post: Publication.State
  var comments: IdentifiedArrayOf<CommentState> = []
  
  var id: String { self.post.id }
}

enum PostAction: Equatable {
  case fetchReactions
  case reactionsResponse(TaskResult<QueryResult<Model.Publication>>)
  case fetchComments
  case commentsResponse(TaskResult<QueryResult<[Model.Publication]>>)
  
  case post(action: Publication.Action)
  case comment(id: CommentState.ID, action: CommentAction)
}

let postReducer = Reducer<PostState, PostAction, RootEnvironment> { state, action, env in
  switch action {
    case .fetchReactions:
      return .task { [publication = state.post.publication] in
        await .reactionsResponse(
          TaskResult {
            try await env.lensApi.reactionsOfPublication(publication)
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
            try await env.lensApi.commentsOfPublication(publication)
          }
        )
      }
      
    case .commentsResponse(let response):
      switch response {
        case .success(let result):
          state.comments.append(
            contentsOf: result.data.map {
              CommentState(comment: Publication.State(publication: $0))
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
