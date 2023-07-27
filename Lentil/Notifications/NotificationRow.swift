// Lentil

import ComposableArchitecture
import SwiftUI


struct NotificationRow: Reducer {
  struct State: Equatable, Identifiable {
    var id: Model.Notification.ID { self.notification.id }
    var notification: Model.Notification
  }
  
  enum Action: Equatable {
    enum LoadingFailure: String {
      case post, comment, profile
    }
    
    case didTapRow
  }
  
  @Dependency(\.navigate) var navigate
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .didTapRow:
          switch state.notification.event {
            case .followed(let id):
              self.navigate.navigate(.profile(id))
              
            case .collected(let item):
              self.navigate.navigate(.publication(item.elementId))
              
            case .commented(let item, _):
              self.navigate.navigate(.publication(item.elementId))
              
            case .mirrored(let item):
              self.navigate.navigate(.publication(item.elementId))
              
            case .mentioned(let item):
              self.navigate.navigate(.publication(item.elementId))
              
            case .reacted(let item):
              self.navigate.navigate(.publication(item.elementId))
          }
          return .none
      }
    }
  }
}
