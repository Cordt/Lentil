//
//  LentilApp.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import SwiftUI
import ComposableArchitecture

@main
struct LentilApp: App {
  
  init() {
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithDefaultBackground()
    navBarAppearance.backgroundColor = UIColor(Theme.Color.primary)
    
    UINavigationBar.appearance().standardAppearance = navBarAppearance
    UINavigationBar.appearance().compactAppearance = navBarAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
  }
  
  var body: some Scene {
    WindowGroup {
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
}
