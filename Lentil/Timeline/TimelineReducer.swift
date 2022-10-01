// Lentil

import ComposableArchitecture
import SwiftUI

struct TimelineState: Equatable {
  var punkState = PunkRaffleState()
}

enum TimelineAction: Equatable {
  case punkAction(PunkRaffleAction)
}

let timelineReducer: Reducer<TimelineState, TimelineAction, RootEnvironment> =
  .combine(
    punkRaffleReducer.pullback(
      state: \.punkState,
      action: /TimelineAction.punkAction,
      environment: { _ in () }
    ),
    
    Reducer { state, action, env in
      switch action {
        case .punkAction(_):
          return .none
      }
    }
  )
