// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation
import UIKit
import XCTestDynamicOverlay
import XMTP


class XMTPConnector {
  static func loadConversations(_ client: XMTP.Client) async -> [XMTPConversation] {
    do {
      return try await client.conversations
        .list()
        .map(XMTPConversation.from(_:))
      
    } catch let error {
      log("Failed to load conversations for \(client.address)", level: .error, error: error)
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
}

extension XMTP.Client: Equatable {
  public static func == (lhs: XMTP.Client, rhs: XMTP.Client) -> Bool {
    lhs.address == rhs.address
  }
}

extension XMTP.DecodedMessage: Equatable {
  public static func == (lhs: DecodedMessage, rhs: DecodedMessage) -> Bool {
    lhs.body == rhs.body && lhs.senderAddress == rhs.senderAddress && lhs.sent == rhs.sent
  }
}

extension DependencyValues {
  var xmtpConnector: XMTPConnectorApi {
    get { self[XMTPConnectorApi.self] }
    set { self[XMTPConnectorApi.self] = newValue }
  }
}

struct XMTPConnectorApi {
  var loadConversations: (_ client: XMTP.Client) async -> [XMTPConversation]
  var loadMessages: (_ conversation: XMTPConversation) async -> [XMTP.DecodedMessage]
}

extension XMTPConnectorApi: DependencyKey {
  static var liveValue: XMTPConnectorApi {
    .init(
      loadConversations: XMTPConnector.loadConversations,
      loadMessages: XMTPConnector.loadMessages
    )
  }
  
  #if DEBUG
  static var previewValue: XMTPConnectorApi {
    .init(
      loadConversations: { _ in MockData.conversations },
      loadMessages: { _ in MockData.messages }
    )
  }
  
  static var testValue: XMTPConnectorApi {
    .init(
      loadConversations: unimplemented("loadConversations"),
      loadMessages: unimplemented("loadMessages")
    )
  }
  #endif
}
