// LentilTests

import ComposableArchitecture
import IdentifiedCollections
import XCTest
@testable import Lentil

@MainActor
final class ConversationsTests: XCTestCase {
  
  func testBundleIsLoadedFromKeychain() async throws {
    let store = TestStore(
      initialState: Conversations.State(),
      reducer: Conversations()
    ) {
      $0.cache.profileByAddress = { _ in MockData.mockProfiles[1] }
      $0.xmtpConnector.address = { "0xabcdef" }
      $0.xmtpConnector.loadConversations = { MockData.conversations }
      $0.xmtpConnector.tryLoadCLient = { true }
    }
    
    let conversationRows = MockData.conversations.map { conversation in
      ConversationRow.State(
        conversation: conversation,
        userAddress: "0xabcdef",
        lastMessage: .init(
          message: MockData.messages[5],
          from: .peer
        ),
        profile: MockData.mockProfiles[1]
      )
    }
    
    await store.send(.didAppear)
    await store.receive(.loadConversations) {
      $0.connectionStatus = .signedIn
    }
    await store.receive(.loadConversations)
    await store.receive(.conversationsResult(.success(conversationRows))) {
      $0.conversations = IdentifiedArrayOf(uniqueElements: conversationRows)
    }
  }
}
