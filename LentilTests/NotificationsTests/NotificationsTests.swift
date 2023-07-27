// LentilTests

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class NotificationsTests: XCTestCase {
  
  func defaultResult() -> PaginatedResult<[Model.Notification]> {
    PaginatedResult(data: MockData.mockNotifications, cursor: .init())
  }
  
  func defaultTestStore() -> TestStore<Notifications.State, Notifications.Action, Notifications.State, Notifications.Action, ()> {
    TestStore(
      initialState: Notifications.State(notificationsCursor: .init()),
      reducer: Notifications()) {
        $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
        $0.defaultsStorageApi.store = { _ in }
        $0.lensApi.notifications = { _, _, _ in await self.defaultResult() }
      }
  }
  
  func testNotificationsAreFetched() async throws {
    let store = self.defaultTestStore()
    
    await store.send(.didAppear)
    await store.receive(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.success(self.defaultResult()))) {
      let rows = self.defaultResult().data.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
      $0.isLoading = false
    }
  }
  
  func testNotificationsAreRefreshed() async throws {
    let notificationsResult = PaginatedResult(data: MockData.mockNotifications, cursor: .init(prev: "prev", next: "next"))
    let store = TestStore(
      initialState: Notifications.State(notificationsCursor: .init(prev: "prev", next: "next")),
      reducer: Notifications()
    ) {
      $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
      $0.defaultsStorageApi.store = { _ in }
      $0.lensApi.notifications = { _, _, _ in notificationsResult }
    }
    
    await store.send(.didRefresh) {
      $0.notificationsCursor = .init()
    }
    await store.receive(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.success(notificationsResult))) {
      let rows = notificationsResult.data.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
      $0.notificationsCursor = .init(prev: "prev", next: "next")
      $0.isLoading = false
    }
  }
  
  func testNotificationsAreSortedCorrectly() async throws {
    let store = TestStore(
      initialState: Notifications.State(notificationsCursor: .init(prev: "prev", next: "next")),
      reducer: Notifications()) {
        $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
        $0.defaultsStorageApi.store = { _ in }
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
    await store.receive(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.success(PaginatedResult(data: [MockData.mockNotifications[1]], cursor: .init(prev: "prev", next: "next"))))) {
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: [NotificationRow.State(notification: MockData.mockNotifications[1])])
      $0.isLoading = false
    }
    
    await store.send(.didRefresh) {
      $0.notificationsCursor = .init()
    }
    await store.receive(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.success(PaginatedResult(data: [MockData.mockNotifications[0]], cursor: .init(prev: "next", next: "nextNext"))))) {
      $0.notificationRows = IdentifiedArrayOf(
        uniqueElements: [
          NotificationRow.State(notification: MockData.mockNotifications[0]),
          NotificationRow.State(notification: MockData.mockNotifications[1])
        ]
      )
      $0.notificationsCursor = .init(prev: "next", next: "nextNext")
      $0.isLoading = false
    }
  }
  
  func testNotificationsAreOrdered() async throws {
    let notificationsResponse = PaginatedResult(
      data: MockData.mockNotifications.shuffled(),
      cursor: .init()
    )
    let store = TestStore(
      initialState: Notifications.State(notificationsCursor: .init()),
      reducer: Notifications()) {
        $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
        $0.defaultsStorageApi.store = { _ in }
        $0.lensApi.notifications = { _, _, _ in notificationsResponse }
      }
    
    await store.send(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.success(notificationsResponse))) {
      let rows = MockData.mockNotifications.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
      $0.isLoading = false
    }
  }
  
  func testLatestReadNotificationIsStored() async throws {
    let expectation = expectation(description: "Should store latest read notification")
    
    let notificationsResponse = PaginatedResult(data: MockData.mockNotifications, cursor: .init())
    let store = TestStore(
      initialState: Notifications.State(notificationsCursor: .init()),
      reducer: Notifications()) {
        $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
        $0.defaultsStorageApi.store = { latestRead in
          XCTAssertNotNil(latestRead as? NotificationsLatestRead)
          expectation.fulfill()
        }
        $0.lensApi.notifications = { _, _, _ in notificationsResponse }
      }
    
    await store.send(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.success(notificationsResponse))) {
      let rows = notificationsResponse.data.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
      $0.isLoading = false
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  func testIsLoadingWhileFetchingNotifications() async throws {
    let store = self.defaultTestStore()
    
    await store.send(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.success(self.defaultResult()))) {
      let rows = self.defaultResult().data.map { notification in
        NotificationRow.State(notification: notification)
      }
      $0.notificationRows = IdentifiedArrayOf(uniqueElements: rows)
      $0.isLoading = false
    }
  }
  
  func testIsLoadingButFailsToFetchNotifications() async throws {
    enum ResponseError: Error { case failed }
    let store = TestStore(
      initialState: Notifications.State(notificationsCursor: .init()),
      reducer: Notifications()) {
        $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
        $0.defaultsStorageApi.store = { _ in }
        $0.lensApi.notifications = { _, _, _ in throw ResponseError.failed }
      }
    
    await store.send(.loadNotifications) {
      $0.isLoading = true
    }
    await store.receive(.notificationsResponse(.failure(ResponseError.failed))) {
      $0.isLoading = false
    }
  }
}





































































