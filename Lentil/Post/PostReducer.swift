// Lentil

import ComposableArchitecture
import SwiftUI


struct PostState: Equatable, Identifiable {
  var post: PublicationState
  var comments: IdentifiedArrayOf<CommentState> = []
  
  var id: String { self.post.id }
}

enum PostAction: Equatable {
  case fetchComments
  case commentsResponse(TaskResult<QueryResult<[Publication]>>)
  
  case post(action: PublicationAction)
  case comment(id: CommentState.ID, action: CommentAction)
}

let postReducer = Reducer<PostState, PostAction, RootEnvironment> { state, action, env in
  switch action {
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
          state.comments.append(contentsOf: result.data.map { CommentState(comment: .init(publication: $0)) })
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
