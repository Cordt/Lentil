// Lentil

import ComposableArchitecture
import Dependencies
import IdentifiedCollections
import SwiftUI


struct Notifications: ReducerProtocol {
  struct State: Equatable {
    var notificationsCursor: Cursor = .init()
    
    var notificationRows: IdentifiedArrayOf<NotificationRow.State> = []
  }
  
  enum Action: Equatable {
    case didAppear
    case didRefresh
    case loadNotifications
    case notificationsResponse(TaskResult<PaginatedResult<[Model.Notification]>>)
    
    case notificationRowAction(NotificationRow.State.ID, NotificationRow.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          return .send(.loadNotifications)
          
        case .didRefresh:
          return .send(.loadNotifications)
          
        case .loadNotifications:
          guard let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
          else { return .none }
          
          return .task { [cursor = state.notificationsCursor] in
            await .notificationsResponse(
              TaskResult {
                try await self.lensApi.notifications(userProfile.id, 50, cursor.next)
              }
            )
          }
          
        case .notificationsResponse(.success(let result)):
          state.notificationsCursor = result.cursor
          result.data.forEach { state.notificationRows.updateOrAppend(NotificationRow.State(notification: $0)) }
          return .none
          
        case .notificationsResponse(.failure(let error)):
          log("Failed to load notifications", level: .error, error: error)
          return .none
          
        case .notificationRowAction:
          return .none
      }
    }
    .forEach(\.notificationRows, action: /Notifications.Action.notificationRowAction) {
      NotificationRow()
    }
  }
}
