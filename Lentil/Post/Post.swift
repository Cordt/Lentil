// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Post: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var post: Publication.State
    var comments: IdentifiedArrayOf<Comment.State> = []
    
    var id: String { self.post.id }
  }
  
  enum Action: Equatable {
    case fetchComments
    case commentsResponse(TaskResult<QueryResult<[Model.Publication]>>)
    
    case post(action: Publication.Action)
    case comment(id: Comment.State.ID, action: Comment.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  
  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \.post,
      action: /Action.post) {
        Publication()
      }
    
    Reduce { state, action in
      switch action {
        case .fetchComments:
          return .task { [publication = state.post.publication] in
            await .commentsResponse(
              TaskResult {
                let userProfile = self.profileStorageApi.load()
                return try await lensApi.commentsOfPublication(publication, userProfile?.id)
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
              log("Could not fetch publications from API", level: .warn, error: error)
              return .none
          }
          
        case .post(_):
          return .none
          
        case .comment(_, _):
          return .none
      }
    }
  }
}
