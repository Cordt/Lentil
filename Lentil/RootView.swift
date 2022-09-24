//
//  RootView.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import SwiftUI


struct RootView: View {
  enum Tabs {
    case timeline, trending, townhall
  }
  
  let store: Store<RootState, RootAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      TabView(
        selection: viewStore.binding(
          get: \.activeTab,
          send: RootAction.setActiveTab
        )
      ) {
        Text("Soon™")
          .tabItem { Label("Timeline", systemImage: "timelapse") }
          .tag(Tabs.timeline)
        
        TrendingView(
          store: self.store.scope(
            state: \.trendingState,
            action: RootAction.trendingAction
          )
        )
        .tabItem { Label("Trending", systemImage: "lightbulb") }
        .tag(Tabs.trending)
        .accentColor(ThemeColor.darkGrey.color)
        
        Text("Soon™")
          .tabItem { Label("Townhall", systemImage: "building.columns") }
          .tag(Tabs.townhall)
      }
      .accentColor(ThemeColor.primaryRed.color)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: RootState(trendingState: .init()),
        reducer: rootReducer,
        environment: RootEnvironment(lensApi: .mock)
      )
    )
  }
}
