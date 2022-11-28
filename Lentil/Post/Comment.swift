// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Comment: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var navigationId: String
    var id: String { self.navigationId }

    var comment: Publication.State    
  }
  
  enum Action: Equatable {
    case commentTapped
    case comment(Publication.Action)
  }
  
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.comment, action: /Action.comment) {
      Publication()
    }
    
    Reduce { state, action in
      switch action {
        case .commentTapped:
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .publication(state.comment.id)
            )
          )
          return .none
          
        case .comment:
          return .none
      }
    }
  }
}

