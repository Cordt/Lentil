// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI

struct Root: ReducerProtocol {
  struct State: Equatable {
    var timelineState: Timeline.State
  }
  
  enum Action: Equatable {
    case timelineAction(Timeline.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \State.timelineState,
      action: /Action.timelineAction
    ) {
      Timeline()
    }
    
    Reduce { state, action in
      switch action {
        case .timelineAction:
          return .none
      }
    }
  }
}
