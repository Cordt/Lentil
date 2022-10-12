// Lentil

import ComposableArchitecture
import SwiftUI

struct Root: ReducerProtocol {
  struct State: Equatable {
    enum Route {
      case settings
      case notifications
    }
    
    var activeTab: RootView.Tabs = .trending
    var route: Route? = nil
    
    var timelineState: Timeline.State
    var trendingState: Trending.State
    var settingsState: Settings.State
  }
  
  enum Action: Equatable {
    case setActiveTab(RootView.Tabs)
    case setRoute(State.Route?)
    
    case timelineAction(Timeline.Action)
    case trendingAction(Trending.Action)
    case settingsAction(Settings.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \State.timelineState,
      action: /Action.timelineAction
    ) {
      Timeline()
    }

    Scope(
      state: \State.trendingState,
      action: /Action.trendingAction
    ) {
      Trending()
    }

    Scope(
      state: \State.settingsState,
      action: /Action.settingsAction
    ) {
      Settings()
    }
    
    Reduce { state, action in
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
  }
}
