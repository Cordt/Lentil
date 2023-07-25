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

struct Notifications: Reducer {
  struct State: Equatable {
    var navigationId: String
    var isLoading: Bool = false
    
    var notificationRows: IdentifiedArrayOf<NotificationRow.State> = []
    
    var notificationsObserver: CollectionObserver<Model.Notification>? = nil
  }
  
  enum Action: Equatable {
    enum NotificationsResponse: Equatable {
      case upsert(_ notifications: [Model.Notification])
      case delete(_ notificationIds: [Model.Notification.ID])
    }
    
    case didAppear
    case didDismiss
    case didRefresh
    
    case observeNotificationUpdates
    case loadNotifications
    case notificationsResponse(NotificationsResponse)
    
    case notificationRowAction(NotificationRow.State.ID, NotificationRow.Action)
  }
  
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.cache) var cache
  @Dependency(\.navigationApi) var navigationApi
  
  enum CancelID { case observeNotifications }
  
  var body: some Reducer<State, Action> {
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
          return .cancel(id: CancelID.observeNotifications)
          
        case .didRefresh:
          return .send(.loadNotifications)
          
        case .observeNotificationUpdates:
          state.notificationsObserver = self.cache.notificationsObserver()
          return .run { [events = state.notificationsObserver?.events] send in
            guard let events else { return }
            for try await event in events {
              switch event {
                case .initial(let notifications), .update(let notifications):
                  await send(.notificationsResponse(.upsert(notifications)))
                  
                case .delete(let deletionKeys):
                  await send(.notificationsResponse(.delete(deletionKeys)))
              }
            }
          }
          .cancellable(id: CancelID.observeNotifications)
          
        case .loadNotifications:
          guard let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
          else { return .none }
          
          state.isLoading = true
          return .run { _ in try await self.cache.refreshNotifications(userProfile.id) }
          
        case .notificationsResponse(let notificationsResponse):
          var notificationRows = state.notificationRows
          switch notificationsResponse {
            case .upsert(let notifications):
              notifications.forEach { notificationRows.updateOrAppend(NotificationRow.State(notification: $0)) }
              
            case .delete(let notificationIds):
              notificationIds.forEach { notificationRows.remove(id: $0) }
              
          }
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
