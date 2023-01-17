// LentilTests
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class ConversationRowTests: XCTestCase {
  
  override func setUpWithError() throws {}
  override func tearDownWithError() throws {}
  
  func testLatestLastMessageAreStored() async throws {
    let profiles: [Model.Profile] = []
    let profilesResponse = PaginatedResult(data: profiles, cursor: .init())
    let store = TestStore(
      initialState: ConversationRow.State(
        conversation: MockData.conversations[0],
        userAddress: "0x-abc-def"
      ),
      reducer: ConversationRow()
    )
    
    store.dependencies.defaultsStorageApi.load = { _ in nil }
    store.dependencies.defaultsStorageApi.store = {
      XCTAssertEqual(($0 as! ConversationsLatestRead), ConversationsLatestRead(latestReadMessages: []))
    }
    store.dependencies.lensApi.profiles = { _ in profilesResponse }
    
    await store.send(.didAppear)
    await store.receive(.loadLatestMessages)
    await store.receive(.profilesResponse(.success(profilesResponse)))
  }
  
  func testNoUnreadMessagesWhenNoMessagesInConversation() async throws {
    let profiles: [Model.Profile] = []
    let profilesResponse = PaginatedResult(data: profiles, cursor: .init())
    let store = TestStore(
      initialState: ConversationRow.State(
        conversation: MockData.conversations[0],
        userAddress: "0x-abc-def"
      ),
      reducer: ConversationRow()
    )
    
    store.dependencies.defaultsStorageApi.load = { _ in ConversationsLatestRead(latestReadMessages: []) }
    store.dependencies.lensApi.profiles = { _ in profilesResponse }
    
    await store.send(.didAppear)
    await store.receive(.loadLatestMessages)
    await store.receive(.profilesResponse(.success(profilesResponse)))
    // No state change expected
  }
  
  func testAllMessagesRead() async throws {
    let profiles: [Model.Profile] = []
    let profilesResponse = PaginatedResult(data: profiles, cursor: .init())
    let store = TestStore(
      initialState: ConversationRow.State(
        conversation: MockData.conversations[0],
        userAddress: "0x-abc-def",
        lastMessage: .init(message: MockData.messages[0], from: .peer)
      ),
      reducer: ConversationRow()
    )
    
    store.dependencies.defaultsStorageApi.load = { _ in
      ConversationsLatestRead(
        latestReadMessages: [
          .init(message: MockData.messages[0], conversationID: MockData.conversations[0].conversationID)
        ]
      )
    }
    store.dependencies.lensApi.profiles = { _ in profilesResponse }
    
    await store.send(.didAppear)
    await store.receive(.loadLatestMessages)
    await store.receive(.profilesResponse(.success(profilesResponse)))
  }
  
  func testLastMessageNotRead() async throws {
    let profiles: [Model.Profile] = []
    let profilesResponse = PaginatedResult(data: profiles, cursor: .init())
    let store = TestStore(
      initialState: ConversationRow.State(
        conversation: MockData.conversations[0],
        userAddress: "0x-abc-def",
        lastMessage: .init(message: MockData.messages[2], from: .peer)
      ),
      reducer: ConversationRow()
    )
    
    store.dependencies.defaultsStorageApi.load = { _ in
      ConversationsLatestRead(
        latestReadMessages: [
          .init(message: MockData.messages[1], conversationID: MockData.conversations[0].conversationID)
        ]
      )
    }
    store.dependencies.lensApi.profiles = { _ in profilesResponse }
    
    await store.send(.didAppear)
    await store.receive(.loadLatestMessages) {
      $0.unreadMessages = true
    }
    await store.receive(.profilesResponse(.success(profilesResponse)))
  }
}
