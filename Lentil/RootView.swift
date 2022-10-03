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
        NavigationView {
          TimelineView(
            store: self.store.scope(
              state: \.timelineState,
              action: RootAction.timelineAction
            )
          )
          .rootToolbar(store: self.store)
        }
        .tabItem { Label("Timeline", systemImage: "timelapse") }
        .tag(Tabs.timeline)
        
        NavigationView {
          TrendingView(
            store: self.store.scope(
              state: \.trendingState,
              action: RootAction.trendingAction
            )
          )
          .rootToolbar(store: self.store)
        }
        .tabItem { Label("Trending", systemImage: "lightbulb") }
        .tag(Tabs.trending)
        .accentColor(ThemeColor.darkGrey.color)
        
        NavigationView {
          Text("Soon™")
            .rootToolbar(store: self.store)
        }
        .tabItem { Label("Townhall", systemImage: "building.columns") }
        .tag(Tabs.townhall)
      }
      .accentColor(ThemeColor.primaryRed.color)
    }
  }
}

extension View {
  func rootToolbar(
    store: Store<RootState, RootAction>
  ) -> some View {
    self.modifier(
      RootToolbar(store: store)
    )
  }
}

struct RootToolbar: ViewModifier {
  var store: Store<RootState, RootAction>
  
  func body(content: Content) -> some View {
    WithViewStore(self.store) { viewStore in
      content
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            NavigationLink(
              destination: SettingsView(
                store: self.store.scope(
                  state: \.settingsState,
                  action: RootAction.settingsAction
                )
              ),
              isActive: viewStore.binding(
                get: \.route,
                send: RootAction.setRoute
              )
              .isPresent(/RootState.RootRoute.settings)) {
                HStack {
                  Button(action: { viewStore.send(.setRoute(.settings))}) {
                    Icon.settings.view(.large)
                  }
                }
              }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
              Button {
                
              } label: {
                Icon.notification.view(.large)
              }
            }
          }
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: RootState(
          timelineState: .init(),
          trendingState: .init(),
          settingsState: .init()
        ),
        reducer: rootReducer,
        environment: RootEnvironment(lensApi: .mock)
      )
    )
  }
}
