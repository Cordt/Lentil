//
//  LentilApp.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import Sentry
import SwiftUI
import UIKit

@main
struct LentilApp: App {
  
  init() {
    SentrySDK.start { options in
      options.dsn = "https://84059162a1c245b58a59c12a70468883@o4504178318639104.ingest.sentry.io/4504178320670720"
      options.debug = false
      
      options.enableAppHangTracking = true
      options.enableFileIOTracking = true
      options.enableCaptureFailedRequests = true
    }
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
