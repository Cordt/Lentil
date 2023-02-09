// Lentil

import ComposableArchitecture
import SwiftUI


struct NotificationRow: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: Model.Notification.ID { self.notification.id }
    var notification: Model.Notification
  }
  
  enum Action: Equatable {
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
          
      }
    }
  }
}
