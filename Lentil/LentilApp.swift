//
//  LentilApp.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import SwiftUI
import ComposableArchitecture
import UIKit

@main
struct LentilApp: App {
  
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
