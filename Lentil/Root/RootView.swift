//
//  RootView.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import SwiftUI


struct RootView: View {
  let store: Store<Root.State, Root.Action>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      if viewStore.isLoading {
        ZStack {
          Theme.Color.primary
            .ignoresSafeArea()
          
          ProgressView(viewStore.loadingText)
            .transition(.scale)
        }
        .onAppear { viewStore.send(.loadingScreenAppeared) }
        .onDisappear { viewStore.send(.loadingScreenDisappeared) }
      }
      else {
        NavigationView {
          TimelineView(
            store: self.store.scope(
              state: \.timelineState,
              action: Root.Action.timelineAction
            )
          )
          .toolbarBackground(Theme.Color.primary, for: .navigationBar)
          .toolbarBackground(.visible, for: .navigationBar)
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: Root.State(
          timelineState: .init()
        ),
        reducer: Root()
      )
    )
  }
}
