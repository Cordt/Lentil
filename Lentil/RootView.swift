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
      TabView(
        selection: viewStore.binding(
          get: \.activeTab,
          send: Root.Action.setActiveTab
        )
      ) {
        NavigationView {
          TimelineView(
            store: self.store.scope(
              state: \.timelineState,
              action: Root.Action.timelineAction
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
              action: Root.Action.trendingAction
            )
          )
          .rootToolbar(store: self.store)
        }
        .tabItem { Label("Trending", systemImage: "lightbulb") }
        .tag(Tabs.trending)
        .accentColor(Theme.Color.darkGrey)
        
        NavigationView {
          Text("Soon™")
            .rootToolbar(store: self.store)
        }
        .tabItem { Label("Townhall", systemImage: "building.columns") }
        .tag(Tabs.townhall)
      }
      .accentColor(Theme.Color.primaryRed)
    }
  }
}

extension View {
  func rootToolbar(
    store: Store<Root.State, Root.Action>
  ) -> some View {
    self.modifier(
      RootToolbar(store: store)
    )
  }
}

struct RootToolbar: ViewModifier {
  var store: Store<Root.State, Root.Action>
  
  func body(content: Content) -> some View {
    WithViewStore(self.store) { viewStore in
      content
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            NavigationLink(
              destination: SettingsView(
                store: self.store.scope(
                  state: \.settingsState,
                  action: Root.Action.settingsAction
                )
              ),
              isActive: viewStore.binding(
                get: \.route,
                send: Root.Action.setRoute
              )
              .isPresent(/Root.State.Route.settings)) {
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
        initialState: Root.State(
          timelineState: .init(),
          trendingState: .init(),
          settingsState: .init()
        ),
        reducer: Root()
      )
    )
  }
}
