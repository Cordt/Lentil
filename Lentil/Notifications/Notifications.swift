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
    var isLoading: Bool = false
    
    var notificationRows: IdentifiedArrayOf<NotificationRow.State> = []
    
    var notificationsObserver: Observer<Model.Notification>? = nil
  }
  
  enum Action: Equatable {
    case didAppear
    case didDismiss
    case didRefresh
    
    case observeNotificationUpdates
    case loadNotifications
    case notificationsResponse([Model.Notification])
    
    case notificationRowAction(NotificationRow.State.ID, NotificationRow.Action)
  }
  
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.cache) var cache
  @Dependency(\.navigationApi) var navigationApi
  
  enum CancelObserveNotificationsID {}
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          return .merge(
            .send(.observeNotificationUpdates),
            .send(.loadNotifications)
          )
          
        case .didDismiss:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.navigationId,
              destination: .showNotifications
            )
          )
          return .cancel(id: CancelObserveNotificationsID.self)
          
        case .didRefresh:
          return .send(.loadNotifications)
          
        case .observeNotificationUpdates:
          state.notificationsObserver = self.cache.notificationsObserver()
          return .run { [events = state.notificationsObserver?.events] send in
            guard let events else { return }
            for try await event in events {
              switch event {
                case .initial(let notifications):
                  await send(.notificationsResponse(notifications))
                case .update(let notifications, deletions: _, insertions: _, modifications: _):
                  await send(.notificationsResponse(notifications))
              }
            }
          }
          .cancellable(id: CancelObserveNotificationsID.self)
          
        case .loadNotifications:
          guard let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
          else { return .none }
          
          state.isLoading = true
          return .fireAndForget { try await self.cache.refreshNotifications(userProfile.id) }
          
        case .notificationsResponse(let notifications):
          var notificationRows = state.notificationRows
          notifications.forEach { notificationRows.updateOrAppend(NotificationRow.State(notification: $0)) }
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
