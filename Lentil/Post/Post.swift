// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Post: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var navigationId: String
    var id: String { self.navigationId }
    var post: Publication.State
    var comments: IdentifiedArrayOf<Comment.State> = []
    
    var commenter: String? {
      self.comments.first?.comment.publication.profile.name ?? self.comments.first?.comment.publication.profile.handle
    }
  }
  
  enum Action: Equatable {
    case dismissView
    case fetchComments
    case commentsResponse(TaskResult<QueryResult<[Model.Publication]>>)
    
    case post(action: Publication.Action)
    case comment(id: Comment.State.ID, action: Comment.Action)
    
    case postTapped
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.post, action: /Action.post) {
      Publication()
    }
    
    Reduce { state, action in
      switch action {
        case .dismissView:
          self.navigationApi.remove(DestinationPath(navigationId: state.id, elementId: state.post.id))
          return .none
          
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
          
        case .post, .comment:
          return .none
         
        case .postTapped:
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              elementId: state.post.id
            )
          )
          return .none
      }
    }
    .forEach(\.comments, action: /Action.comment) {
      Comment()
    }
  }
}
