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
    var body: some Scene {
        WindowGroup {
            ContentView(
              store: Store(
                initialState: AppState(),
                reducer: reducer,
                environment: .live
              )
            )
        }
    }
}
