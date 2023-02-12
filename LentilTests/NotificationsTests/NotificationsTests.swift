// LentilTests

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class NotificationsTests: XCTestCase {
  
  func testNotificationsAreFetched() async throws {
    let notificationsResult = PaginatedResult(data: MockData.mockNotifications, cursor: .init())
    let store = TestStore(
      initialState: Notifications.State(navigationId: "abc-def"),
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
    let notificationsResult = PaginatedResult(data: MockData.mockNotifications, cursor: .init(prev: "prev", next: "next"))
    let store = TestStore(
      initialState: Notifications.State(navigationId: "abc-def", notificationsCursor: .init(prev: "prev", next: "next")),
      reducer: Notifications()
    ) {
      $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
      $0.lensApi.notifications = { _, _, _ in notificationsResult }
    }
    
    await store.send(.didRefresh) {
      $0.notificationsCursor = .init()
    }
    await store.receive(.loadNotifications)
    await store.receive(.notificationsResponse(.success(notificationsResult))) {
      let rows = notificationsResult.data.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
      $0.notificationsCursor = .init(prev: "prev", next: "next")
    }
  }
  
  func testNotificationsAreSortedCorrectly() async throws {
    let store = TestStore(
      initialState: Notifications.State(navigationId: "abc-def", notificationsCursor: .init(prev: "prev", next: "next")),
      reducer: Notifications()) {
        $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
        $0.lensApi.notifications = { _, _, cursor in
          if cursor == "next" {
            return PaginatedResult(data: [MockData.mockNotifications[1]], cursor: .init(prev: "prev", next: "next"))
          }
          else {
            return PaginatedResult(data: [MockData.mockNotifications[0]], cursor: .init(prev: "next", next: "nextNext"))
          }
        }
      }
    
    await store.send(.didAppear)
    await store.receive(.loadNotifications)
    await store.receive(.notificationsResponse(.success(PaginatedResult(data: [MockData.mockNotifications[1]], cursor: .init(prev: "prev", next: "next"))))) {
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: [NotificationRow.State(notification: MockData.mockNotifications[1])])
    }
    
    await store.send(.didRefresh) {
      $0.notificationsCursor = .init()
    }
    await store.receive(.loadNotifications)
    await store.receive(.notificationsResponse(.success(PaginatedResult(data: [MockData.mockNotifications[0]], cursor: .init(prev: "next", next: "nextNext"))))) {
      $0.notificationRows = IdentifiedArrayOf(
        uniqueElements: [
          NotificationRow.State(notification: MockData.mockNotifications[0]),
          NotificationRow.State(notification: MockData.mockNotifications[1])
        ]
      )
      $0.notificationsCursor = .init(prev: "next", next: "nextNext")
    }
  }
}





































































