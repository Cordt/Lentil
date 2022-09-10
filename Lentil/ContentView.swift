//
//  ContentView.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
  var color: Color = .red
}
enum AppAction: Equatable {
  case colorButtonTapped
}

let reducer = Reducer<AppState, AppAction, Void> { state, action, _ in
  switch action {
    case .colorButtonTapped:
      let randomColor: Color = [.red, .green, .blue, .yellow, .purple, .gray]
        .randomElement()!
      state.color = randomColor
      return .none
  }
}

struct ContentView: View {
  let store = Store(
    initialState: AppState(),
    reducer: reducer,
    environment: ()
  )
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Button("Change color") {
          viewStore.send(.colorButtonTapped)
        }
        .tint(viewStore.color)
        .buttonStyle(.borderedProminent)
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
