//
//  ContentView.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
  var publicationsResponse: String = ""
}

enum AppAction: Equatable {
  case publicationsButtonTapped
  case publicationsResponse(String)
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
    case .publicationsButtonTapped:
      return .task {
        let publications = try await env.lensApi.getPublications(10, .latest, [.post])
          .reduce("") { text, next in
            var updatedText = ""
            updatedText.append("\n")
            updatedText.append("\(next.name)")
            updatedText.append("\n")
            updatedText.append("\(next.content)")
            updatedText.append("\n")
            return text + updatedText
          }
        return .publicationsResponse(publications)
      }
      
    case let .publicationsResponse(response):
      state.publicationsResponse = response
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
          viewStore.send(.publicationsButtonTapped)
        }
        .tint(.red)
        .buttonStyle(.borderedProminent)
        
        Text(viewStore.publicationsResponse)
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
