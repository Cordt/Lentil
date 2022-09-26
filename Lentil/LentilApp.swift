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
  static let punkImages = slice(image: UIImage(named: "punks")!, into: 100)
  
  var body: some Scene {
    WindowGroup {
      RootView(
        store: Store(
          initialState: RootState(
            punkImages: LentilApp.punkImages,
            timelineState: .init(images: LentilApp.punkImages),
            trendingState: .init()
          ),
          reducer: rootReducer,
          environment: RootEnvironment(lensApi: .live)
        )
      )
    }
  }
}
