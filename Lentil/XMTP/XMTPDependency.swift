// Lentil

import Dependencies
import XMTP


extension DependencyValues {
  var xmtpConnector: XMTPConnectorApi {
    get { self[XMTPConnectorApi.self] }
    set { self[XMTPConnectorApi.self] = newValue }
  }
}

struct XMTPConnectorApi {
  var address: () throws -> String
  var tryLoadCLient: () -> Bool
  var createClient: () async -> Void
  var disconnect: (_ removing: [XMTPConversation]) throws -> Void
  var createConversation: (_ peerAddress: String, _ conversationID: XMTPClient.ConversationID) async throws -> XMTPConversation
  var loadStoredConversations: () throws -> [XMTPConversation]
  var loadConversations: () async throws -> [XMTPConversation]
  var loadMessages: (_ conversation: XMTPConversation) async -> [XMTP.DecodedMessage]
  var lastMessage: (_ conversation: XMTPConversation) async -> XMTP.DecodedMessage?
  var streamMessages: (_ conversation: XMTPConversation) async -> AsyncThrowingStream<XMTP.DecodedMessage, Error>
}

extension XMTPConnectorApi: DependencyKey {
  static var liveValue: XMTPConnectorApi {
    .init(
      address: XMTPConnector.shared.address,
      tryLoadCLient: XMTPConnector.shared.tryLoadClient,
      createClient: XMTPConnector.shared.createClient,
      disconnect: XMTPConnector.shared.disconnect,
      createConversation: XMTPConnector.shared.createConversation,
      loadStoredConversations: XMTPConnector.shared.loadStoredConversations,
      loadConversations: XMTPConnector.shared.loadConversations,
      loadMessages: XMTPConnector.loadMessages,
      lastMessage: XMTPConnector.lastMessage,
      streamMessages: XMTPConnector.streamMessages
    )
  }
}


#if DEBUG
import XCTestDynamicOverlay

extension XMTPConnectorApi {
  static var previewValue: XMTPConnectorApi {
    .init(
      address: { "0xabcdef" },
      tryLoadCLient: { true },
      createClient: { },
      disconnect: { _ in },
      createConversation: { _, _ in MockData.conversations[0] },
      loadStoredConversations: { MockData.conversations },
      loadConversations: { MockData.conversations },
      loadMessages: { _ in MockData.messages },
      lastMessage: { _ in MockData.messages.first },
      streamMessages: { _ in AsyncThrowingStream(unfolding: { nil }) }
    )
  }
  
  static var testValue: XMTPConnectorApi {
    .init(
      address: unimplemented("address"),
      tryLoadCLient: unimplemented("tryLoadClient"),
      createClient: unimplemented("createClient"),
      disconnect: unimplemented("disconnect"),
      createConversation: unimplemented("createConversation"),
      loadStoredConversations: unimplemented("loadStoredConversations"),
      loadConversations: unimplemented("loadConversations"),
      loadMessages: unimplemented("loadMessagess"),
      lastMessage: unimplemented("lastMessage"),
      streamMessages: unimplemented("streamMessages")
    )
  }
}
#endif
