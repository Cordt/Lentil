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
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .comment:
        return .none
    }
  }
}
