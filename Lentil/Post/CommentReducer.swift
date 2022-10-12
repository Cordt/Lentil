// Lentil

import ComposableArchitecture
import SwiftUI


struct CommentState: Equatable, Identifiable {
  var comment: Publication.State
  
  var id: String { self.comment.id }
}

enum CommentAction: Equatable {
  case comment(Publication.Action)
}

let commentReducer: Reducer<CommentState, CommentAction, RootEnvironment> = Reducer { state, action, env in
  switch action {
    case .comment(_):
      return .none
  }
}
