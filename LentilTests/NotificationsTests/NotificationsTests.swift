// LentilTests

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class NotificationsTests: XCTestCase {
  
  func testNotificationsAreFetched() async throws {
    let notificationsResult = PaginatedResult(data: MockData.mockNotifications, cursor: .init())
    let store = TestStore(
      initialState: Notifications.State(),
      reducer: Notifications()
    ) {
      $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
      $0.lensApi.notifications = { _, _, _ in notificationsResult }
    }
    
    await store.send(.didAppear)
    await store.receive(.loadNotifications)
    await store.receive(.notificationsResponse(.success(notificationsResult))) {
      let rows = notificationsResult.data.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
    }
  }
  
  func testNotificationsAreRefreshed() async throws {
    let notificationsResult = PaginatedResult(data: MockData.mockNotifications, cursor: .init())
    let store = TestStore(
      initialState: Notifications.State(),
      reducer: Notifications()
    ) {
      $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
      $0.lensApi.notifications = { _, _, _ in notificationsResult }
    }
    
    await store.send(.didRefresh)
    await store.receive(.loadNotifications)
    await store.receive(.notificationsResponse(.success(notificationsResult))) {
      let rows = notificationsResult.data.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
    }
  }
}
