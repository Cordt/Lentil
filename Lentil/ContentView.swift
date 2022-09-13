//
//  ContentView.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
  var pingResponse: String = ""
}

enum AppAction: Equatable {
  case pingButtonTapped
  case pingResponse(String)
}

struct AppEnvironment {
  let lensApi: LensApi
}

extension AppEnvironment {
  static var live: Self = .init(
    lensApi: .live
  )
}

let reducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, env in
  switch action {
    case .pingButtonTapped:
      return .task {
        let ping = try await env.lensApi.getPublications(10, .latest, [.post])
          .reduce("") { text, next in
            var updatedText = ""
            updatedText.append("\n")
            updatedText.append("\(next.name)")
            updatedText.append("\n")
            updatedText.append("\(next.content)")
            updatedText.append("\n")
            return text + updatedText
          }
        return .pingResponse(ping)
      }
      
    case let .pingResponse(response):
      state.pingResponse = response
      return .none
      
  }
}

struct ContentView: View {
  let store = Store(
    initialState: AppState(),
    reducer: reducer,
    environment: .live
  )
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Button("Ping API") {
          viewStore.send(.pingButtonTapped)
        }
        .tint(.red)
        .buttonStyle(.borderedProminent)
        
        Text(viewStore.pingResponse)
          .font(.subheadline)
      }
      .padding()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
