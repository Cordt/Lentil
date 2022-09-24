// Lentil

import ComposableArchitecture
import SwiftUI


struct CommentState: Equatable, Identifiable {
  var comment: PublicationState
  
  var id: String { self.comment.id }
}

enum CommentAction: Equatable {
  case comment(PublicationAction)
}

let commentReducer: Reducer<CommentState, CommentAction, RootEnvironment> = Reducer { state, action, env in
  switch action {
    case .comment(_):
      return .none
  }
}
