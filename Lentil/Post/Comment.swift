// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Comment: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var comment: Publication.State
    
    var id: String { self.comment.id }
  }
  
  enum Action: Equatable {
    case comment(Publication.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.comment, action: /Action.comment) {
      Publication()
    }
    
    Reduce { state, action in
      switch action {
        case .comment:
          return .none
      }
    }
  }
}
