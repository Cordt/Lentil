// LentilTests

import ComposableArchitecture
import IdentifiedCollections
import XCTest
@testable import Lentil

@MainActor
final class CreateConversationTests: XCTestCase {
  
  func testSearchStartsOnlyWithEnoughCharacters() {
    let store = TestStore(
      initialState: CreateConversation.State(),
      reducer: CreateConversation()
    )
    
    store.send(.updateSearchText("a")) { $0.searchText = "a" }
    store.send(.updateSearchText("ab")) { $0.searchText = "ab" }
  }
  
  func testNewConversationIsCreated() async throws {
    let searchResult = PaginatedResult(data: MockData.mockProfiles, cursor: .init())
    let store = TestStore(
      initialState: CreateConversation.State(),
      reducer: CreateConversation()
    ) {
      $0.cache.updateOrAppendProfile = { _ in }
      $0.defaultsStorageApi.load = { _ in MockData.mockUserProfile }
      $0.lensApi.searchProfiles = { _, _ in searchResult }
      $0.xmtpConnector.address = { "0xabcdef" }
      $0.xmtpConnector.createConversation = { _, _ in MockData.conversations[0] }
    }
    
    // Search
    await store.send(.updateSearchText("cor")) {
      $0.searchText = "cor"
      $0.searchInFlight = true
    }
    await store.receive(.startSearch)
    await store.receive(.searchedProfilesResult(.success(searchResult))) {
      $0.searchInFlight = false
      $0.searchResult = IdentifiedArrayOf(uniqueElements: searchResult.data)
    }
    
    // Create Conversation
    await store.send(.rowTapped(id: searchResult.data[0].id))
    await store.receive(.dismissAndOpenConversation(MockData.conversations[0], "0xabcdef")) {
      $0.searchText = ""
      $0.searchResult = []
    }
  }
}
