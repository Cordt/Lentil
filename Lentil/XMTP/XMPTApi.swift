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
  fileprivate var conversations: XMTPConversations
  static let shared: XMTPConnector = .init()
  
  @Dependency(\.keychainApi) var keychainApi
  
  private init() {
    self.conversations = XMTPConversations()
  }
  
  func address() throws -> String {
    guard let client = self.client
    else { throw XMTPConnectorError.clientNotConnected }
    
    return client.address()
  }
  
  func tryLoadClient() -> Bool {
    do {
      if self.keychainApi.hasDataStored(XMTPSession.current.key) {
        let bundle = try self.keychainApi.getData(XMTPSession.current.key)
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
  
  func disconnect(removing: [XMTPConversation]) {
    do {
      try self.delete(conversations: removing)
      try self.keychainApi.delete(XMTPSession.current.key)
      self.client = nil
    }
    catch let error {
      log("Failed to disconnect XMTP client", level: .error, error: error)
    }
  }
  
  func createConversation(_ peerAddress: String, _ conversationID: XMTPClient.ConversationID) async throws -> XMTPConversation {
    guard let client = self.client
    else { throw XMTPConnectorError.clientNotConnected }
    
    let conversation = try await client.newConversation(peerAddress, conversationID)
    try self.store(conversation: conversation)
    return conversation
  }
  
  func loadStoredConversations() throws -> [XMTPConversation] {
    guard let client = self.client
    else { throw XMTPConnectorError.clientNotConnected }
    
    do {
      let storedConversationData = try self.loadStored()
      return try storedConversationData.map {
        let container = try JSONDecoder().decode(XMTP.ConversationContainer.self, from: $0)
        return client.decodeConversation(container)
      }
    }
    catch let error {
      print(error)
      return []
    }
  }
  
  func loadConversations() async throws -> [XMTPConversation] {
    guard let client = self.client
    else { throw XMTPConnectorError.clientNotConnected }
    
    do {
      let conversations = try await client.conversations()
        .list()
        .map(XMTPConversation.from(_:))
      
      try conversations.forEach { try self.store(conversation: $0) }
      return conversations
      
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
  
  
  private func loadStored() throws -> [Data] {
    let decoder = JSONDecoder()
    
    guard self.keychainApi.hasDataStored(self.conversations.key)
    else { return [] }
    
    let conversations = try decoder.decode(
      XMTPConversations.self,
      from: try self.keychainApi.getData(self.conversations.key)
    )
    
    var conversationData: [Data] = []
    for id in conversations.ids {
      if self.keychainApi.hasDataStored(id) {
        conversationData.append(try self.keychainApi.getData(id))
      }
    }
    
    self.conversations = conversations
    return conversationData
  }
  
  private func store(conversation: XMTPConversation) throws {
    let encoder = JSONEncoder()
    
    let encodedContainer = try encoder.encode(conversation.container())
    try self.keychainApi.storeData(encodedContainer, conversation.key)
    
    self.conversations.ids.insert(conversation.key)
    let encodedIds = try encoder.encode(self.conversations)
    try self.keychainApi.storeData(encodedIds, self.conversations.key)
  }
  
  private func delete(conversations: [XMTPConversation]) throws {
    for conversation in conversations { try self.keychainApi.delete(conversation.key) }
    try self.keychainApi.delete(self.conversations.key)
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
  var disconnect: (_ removing: [XMTPConversation]) throws -> Void
  var createConversation: (_ peerAddress: String, _ conversationID: XMTPClient.ConversationID) async throws -> XMTPConversation
  var loadStoredConversations: () throws -> [XMTPConversation]
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
      loadStoredConversations: XMTPConnector.shared.loadStoredConversations,
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
      disconnect: { _ in },
      createConversation: { _, _ in MockData.conversations[0] },
      loadStoredConversations: { MockData.conversations },
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
      loadStoredConversations: unimplemented("loadStoredConversations"),
      loadConversations: unimplemented("loadConversations"),
      loadMessages: unimplemented("loadMessagess"),
      streamMessages: unimplemented("streamMessages")
    )
  }
}
#endif
