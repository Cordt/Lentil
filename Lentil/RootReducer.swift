// Lentil

import ComposableArchitecture
import SwiftUI

struct Root: ReducerProtocol {
  struct State: Equatable {
    var trendingState: Trending.State
  }
  
  enum Action: Equatable {
    case trendingAction(Trending.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \State.trendingState,
      action: /Action.trendingAction
    ) {
      Trending()
    }
    
    Reduce { state, action in
      switch action {
        case .trendingAction:
          return .none
      }
    }
  }
}
