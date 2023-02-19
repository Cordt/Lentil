// Lentil

import ComposableArchitecture
import Dependencies
import IdentifiedCollections
import SwiftUI


struct NotificationsLatestRead: Codable, DefaultsStorable {
  static var profileKey: String { "notifications-latest-read" }
  
  var id: String
  var createdAt: Date
}

struct Notifications: ReducerProtocol {
  struct State: Equatable {
    var navigationId: String
    var notificationsCursor: Cursor = .init()
    var isLoading: Bool = false
    
    var notificationRows: IdentifiedArrayOf<NotificationRow.State> = []
  }
  
  enum Action: Equatable {
    case didAppear
    case didDismiss
    case didRefresh
    case loadNotifications
    case notificationsResponse(TaskResult<PaginatedResult<[Model.Notification]>>)
    
    case notificationRowAction(NotificationRow.State.ID, NotificationRow.Action)
  }
  
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  
  enum CancelLoadNotificationsID {}
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          return .send(.loadNotifications)
          
        case .didDismiss:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.navigationId,
              destination: .showNotifications
            )
          )
          return .cancel(id: CancelLoadNotificationsID.self)
          
        case .didRefresh:
          state.notificationsCursor = .init()
          return .send(.loadNotifications)
          
        case .loadNotifications:
          guard let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
          else { return .none }
          
          state.isLoading = true
          
          return .task { [cursor = state.notificationsCursor] in
            await .notificationsResponse(
              TaskResult {
                try await self.lensApi.notifications(userProfile.id, 50, cursor.next)
              }
            )
          }
          .cancellable(id: CancelLoadNotificationsID.self)
          
        case .notificationsResponse(.success(let result)):
          state.notificationsCursor = result.cursor
          var notificationRows = state.notificationRows
          result.data.forEach { notificationRows.updateOrAppend(NotificationRow.State(notification: $0)) }
          notificationRows.sort { $0.notification.createdAt > $1.notification.createdAt }
          state.notificationRows = notificationRows
          state.isLoading = false
          
          if let latestNotification = notificationRows.first {
            let latestReadNotification = NotificationsLatestRead(
              id: latestNotification.id,
              createdAt: latestNotification.notification.createdAt
            )
            try? self.defaultsStorageApi.store(latestReadNotification)
          }
          return .none
          
        case .notificationsResponse(.failure(let error)):
          state.isLoading = false
          log("Failed to load notifications", level: .error, error: error)
          return .none
          
          
        // MARK: Child Reducer Actions
          
        case .notificationRowAction(_, let notificationAction):
          if case .handleFailure(let failure, let error) = notificationAction {
            // TODO: Add Toast
            log("Failed to load \(failure.rawValue) from notification.", level: .warn, error: error)
          }
          return .none
      }
    }
    .forEach(\.notificationRows, action: /Notifications.Action.notificationRowAction) {
      NotificationRow()
    }
  }
}
