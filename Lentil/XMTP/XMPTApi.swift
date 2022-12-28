// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation
import UIKit
import XCTestDynamicOverlay
import XMTP


class XMTPConnector {
  enum ConnectionStatus {
    case disconnected, connecting, connected(Client), error(String)
  }
  var connectionStatus: ConnectionStatus
  var account: XMTP.Account
  
  static let shared: XMTPConnector = XMTPConnector()
  
  private init() {
    self.connectionStatus = .disconnected
    self.account = try! XMTP.Account.create()
  }
  
  func getConnectionStatus() -> ConnectionStatus {
    self.connectionStatus
  }
  
  func connectWallet() {
    self.connectionStatus = .connecting
    
    do {
      switch try self.account.preferredConnectionMethod() {
        case .qrCode:
          log("QR Code login not supported", level: .error)
          
        case let .redirect(url):
          UIApplication.shared.open(url)
          
        case .manual:
          log("Manual URL opening not supported", level: .error)
      }
      
      Task {
        do {
          try await self.account.connect()
          
          for _ in 0 ... 30 {
            if self.account.isConnected {
              let client = try await Client.create(account: self.account)
              self.connectionStatus = .connected(client)
              return
            }
            try await Task.sleep(for: .seconds(1))
          }
          self.connectionStatus = .error("Timed out waiting to connect (30 seconds)")
          log("Timed out waiting to connect (30 seconds)", level: .debug)
          
        } catch {
          await MainActor.run {
            self.connectionStatus = .disconnected
            log("Error connecting with WalletConnect", level: .error, error: error)
          }
        }
      }
    } catch {
      self.connectionStatus = .disconnected
      log("No acceptable connection methods found", level: .error, error: error)
    }
  }
  
  func loadConversations() async -> [XMTPConversation] {
    guard case .connected(let client) = self.connectionStatus
    else { return [] }
    
    do {
      return try await client.conversations
        .list()
        .map(XMTPConversation.from(_:))
      
    } catch let error {
      log("Failed to load conversations for \(client.address)", level: .error, error: error)
      return []
    }
  }
  
  func loadMessages(for conversation: XMTPConversation) async -> [XMTP.DecodedMessage] {
    do {
      return try await conversation.messages()
      
    } catch let error {
      log("Failed to load messages for \(conversation.peerAddress)", level: .error, error: error)
      return []
    }
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
  var connectionStatus: () -> XMTPConnector.ConnectionStatus
  var connectWallet: () -> Void
  var loadConversations: () async -> [XMTPConversation]
  var loadMessages: (_ conversation: XMTPConversation) async -> [XMTP.DecodedMessage]
}

extension XMTPConnectorApi: DependencyKey {
  static var liveValue: XMTPConnectorApi {
    .init(
      connectionStatus: XMTPConnector.shared.getConnectionStatus,
      connectWallet: XMTPConnector.shared.connectWallet,
      loadConversations: XMTPConnector.shared.loadConversations,
      loadMessages: XMTPConnector.shared.loadMessages
    )
  }
  
  #if DEBUG
  static var previewValue: XMTPConnectorApi {
    .init(
      connectionStatus: { .disconnected },
      connectWallet: {},
      loadConversations: { MockData.conversations },
      loadMessages: { _ in MockData.messages }
    )
  }
  
  static var testValue: XMTPConnectorApi {
    .init(
      connectionStatus: unimplemented("connectionStatus"),
      connectWallet: unimplemented("connectWallet"),
      loadConversations: unimplemented("loadConversations"),
      loadMessages: unimplemented("loadMessages")
    )
  }
  #endif
}
