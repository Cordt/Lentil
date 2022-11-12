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
  
  let store: Store<Root.State, Root.Action>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        TrendingView(
          store: self.store.scope(
            state: \.trendingState,
            action: Root.Action.trendingAction
          )
        )
      }
      .accentColor(Theme.Color.primary)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: Root.State(
          trendingState: .init()
        ),
        reducer: Root()
      )
    )
  }
}
