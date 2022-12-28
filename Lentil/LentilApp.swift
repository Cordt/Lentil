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
      options.dsn = "https://\(LentilEnvironment.shared.sentryDsn)"
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
          initialState: Root.State(),
          reducer: Root()
        )
      )
    }
  }
}
