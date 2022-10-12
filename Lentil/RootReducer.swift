// Lentil

import ComposableArchitecture
import SwiftUI

struct RootState: Equatable {
  enum RootRoute {
    case settings
    case notifications
  }
  
  var activeTab: RootView.Tabs = .trending
  var route: RootRoute? = nil
  
  var timelineState: TimelineState
  var trendingState: TrendingState
  var settingsState: Settings.State
}

enum RootAction: Equatable {
  case setActiveTab(RootView.Tabs)
  case setRoute(RootState.RootRoute?)
  
  case timelineAction(TimelineAction)
  case trendingAction(TrendingAction)
  case settingsAction(Settings.Action)
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
  
  AnyReducer {
    Settings()
  }
    .pullback(
      state: \.settingsState,
      action: /RootAction.settingsAction,
      environment: { _ in ()}
    ),
  
  Reducer { state, action, _ in
    switch action {
      case .setActiveTab(let tab):
        state.activeTab = tab
        return .none
        
      case .setRoute(let route):
        state.route = route
        return .none
        
      case .timelineAction(_):
        return .none
        
      case .trendingAction(_):
        return .none
        
      case .settingsAction(_):
        return .none
    }
  }
)
