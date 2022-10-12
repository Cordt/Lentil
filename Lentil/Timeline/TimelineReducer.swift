// Lentil

import ComposableArchitecture
import SwiftUI

struct Timeline: ReducerProtocol {
  struct State: Equatable {
    var punkState = PunkRaffle.State()
  }
  
  enum Action: Equatable {
    case punkAction(PunkRaffle.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \.punkState,
      action: /Action.punkAction) {
        PunkRaffle()
      }
    
    Reduce { state, action in
      switch action {
        case .punkAction(_):
          return .none
      }
    }
  }
}
