// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation
import UIKit
import XMTP


class XMTPConnector {
  enum XMTPConnectorError: Error {
    case clientNotConnected
  }
  
  fileprivate var client: XMTPClient?
  static let shared: XMTPConnector = .init()
  
  private init() {}
  
  func address() throws -> String {
    guard let client = self.client
    else { throw XMTPConnectorError.clientNotConnected }
    
    return client.address()
  }
  
  func tryLoadClient() -> Bool {
    do {
      if KeychainStorage.shared.checkForData(storable: XMTPSession.current) {
        let bundle = try KeychainStorage.shared.getData(storable: XMTPSession.current)
        self.client = try XMTPClient(serializedKeyBundle: bundle)
        return true
      }
      else {
        log("No Keychain Bundle stored for XMTP", level: .info)
        return false
      }
    }
    catch let error {
      log("Failed to create client from Keychain Bundle for XMTP", level: .error, error: error)
      return false
    }
  }
  
  func createClient() async -> Void {
    do {
      self.client = try await XMTPClient(account: WalletConnector.shared)
    }
    catch let error {
      log("Failed to create client for XMTP", level: .error, error: error)
    }
  }
  
  func disconnect() {
    do {
      try KeychainStorage.shared.delete(storable: XMTPSession.current)
      self.client = nil
    }
    catch let error {
      log("Failed to disconnect XMTP client", level: .error, error: error)
    }
  }
  
  func createConversation(_ peerAddress: String, _ conversationID: XMTPClient.ConversationID) async throws -> XMTPConversation {
    guard let client = self.client
    else { throw XMTPConnectorError.clientNotConnected }
    
    return try await client.newConversation(peerAddress, conversationID)
  }
  
  func loadConversations() async throws -> [XMTPConversation] {
    guard let client = self.client
    else { throw XMTPConnectorError.clientNotConnected }
    
    do {
      return try await client.conversations()
        .list()
        .map(XMTPConversation.from(_:))
      
    } catch let error {
      log("Failed to load conversations for \(client.address())", level: .error, error: error)
      return []
    }
  }
  
  static func loadMessages(for conversation: XMTPConversation) async -> [XMTP.DecodedMessage] {
    do {
      return try await conversation.messages()
      
    } catch let error {
      log("Failed to load messages for \(conversation.peerAddress)", level: .error, error: error)
      return []
    }
  }
  
  static func streamMessages(for conversation: XMTPConversation) -> AsyncThrowingStream<XMTP.DecodedMessage, Error> {
    return conversation.streamMessages()
  }
}

extension XMTP.DecodedMessage: Equatable {
  public static func == (lhs: DecodedMessage, rhs: DecodedMessage) -> Bool {
    lhs.bodyText == rhs.bodyText && lhs.senderAddress == rhs.senderAddress && lhs.sent == rhs.sent
  }
}

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
  var disconnect: () throws -> Void
  var createConversation: (_ peerAddress: String, _ conversationID: XMTPClient.ConversationID) async throws -> XMTPConversation
  var loadConversations: () async throws -> [XMTPConversation]
  var loadMessages: (_ conversation: XMTPConversation) async -> [XMTP.DecodedMessage]
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
      loadConversations: XMTPConnector.shared.loadConversations,
      loadMessages: XMTPConnector.loadMessages,
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
      disconnect: {  },
      createConversation: { _, _ in MockData.conversations[0] },
      loadConversations: { MockData.conversations },
      loadMessages: { _ in MockData.messages },
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
      loadConversations: unimplemented("loadConversations"),
      loadMessages: unimplemented("loadMessagess"),
      streamMessages: unimplemented("streamMessages")
    )
  }
}
#endif
