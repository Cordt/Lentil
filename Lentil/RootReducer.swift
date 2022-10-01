// Lentil

import ComposableArchitecture
import SwiftUI

struct RootState: Equatable {
  var activeTab: RootView.Tabs = .trending
  
  var timelineState: TimelineState
  var trendingState: TrendingState
}

enum RootAction: Equatable {
  case setActiveTab(RootView.Tabs)
  
  case timelineAction(TimelineAction)
  case trendingAction(TrendingAction)
}

struct RootEnvironment {
  let lensApi: LensApi
}

extension RootEnvironment {
  static var live: Self = .init(
    lensApi: .live
  )
  
#if DEBUG
  static var mock: Self = .init(
    lensApi: .mock
  )
#endif
}

let rootReducer: Reducer<RootState, RootAction, RootEnvironment> = .combine(
  timelineReducer.pullback(
    state: \RootState.timelineState,
    action: /RootAction.timelineAction,
    environment: { $0 }
  ),
  
  trendingReducer.pullback(
    state: \RootState.trendingState,
    action: /RootAction.trendingAction,
    environment: { $0 }
  ),
  
  Reducer { state, action, _ in
    switch action {
      case .setActiveTab(let tab):
        state.activeTab = tab
        return .none
        
        
      case .timelineAction(_):
        return .none
        
      case .trendingAction(_):
        return .none
    }
  }
)
