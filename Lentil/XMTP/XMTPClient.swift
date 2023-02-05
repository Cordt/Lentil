// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import XMTP


class XMTPClient {
  enum ConversationID {
    case none, lens(_ peerProfileID: String, _ userProfileID: String)
    
    func build() -> InvitationV1.Context? {
      switch self {
        case .none:
          return nil
          
        case .lens(let peerProfileID, let userProfileID):
          guard let peerProfileIDParsed = hexToDecimal(peerProfileID),
                let userProfileIDParsed = hexToDecimal(userProfileID)
          else {
            log("Failed to parse user profiles to build XMTP Conversation ID", level: .error)
            return nil
          }
          let suffix = peerProfileIDParsed < userProfileIDParsed
          ? "/\(peerProfileID)-\(userProfileID)"
          : "/\(userProfileID)-\(peerProfileID)"
          switch LentilEnvironment.shared.xmtpEnvironment {
            case .local:      return InvitationV1.Context(conversationID: "lens.local/dm\(suffix)")
            case .dev:        return InvitationV1.Context(conversationID: "lens.dev/dm\(suffix)")
            case .production: return InvitationV1.Context(conversationID: "lens.dev/dm\(suffix)")
          }
      }
    }
  }
  
  private var client: XMTP.Client
  
  var address: () -> String
  var conversations: () -> XMTP.Conversations
  var newConversation: (_ peerAddress: String, _ conversationID: ConversationID) async throws -> XMTPConversation
  var contacts: () -> XMTP.Contacts
  var environment: () -> XMTPEnvironment
  
  init(account: SigningKey) async throws {
    let options = XMTP.ClientOptions(api: .init(env: LentilEnvironment.shared.xmtpEnvironment))
    let client = try await XMTP.Client.create(account: account, options: options)
    
    // Store Key Bundle in Keychain
    let serializedBundle = try client.privateKeyBundle.serializedData()
    try KeychainStorage.shared.storeData(data: serializedBundle, for: XMTPSession.current)
    
    self.client = client
    self.address = { client.address }
    self.conversations = { client.conversations }
    self.newConversation = { peerAddress, conversationID in
      let conversation = try await client.conversations.newConversation(with: peerAddress, context: conversationID.build())
      log("Created conversation with Conversation ID and topic: \(conversationID.build()?.conversationID ?? "none"), \(conversation.topic)", level: .info)
      return XMTPConversation.from(conversation)
    }
    self.contacts = { client.contacts }
    self.environment = { client.environment }
  }
  
  init(serializedKeyBundle: Data) throws {
    let options = XMTP.ClientOptions(api: .init(env: LentilEnvironment.shared.xmtpEnvironment))
    let bundle = try PrivateKeyBundle(serializedData: serializedKeyBundle)
    let client = try XMTP.Client.from(bundle: bundle, options: options)
    
    self.client = client
    self.address = { client.address }
    self.conversations = { client.conversations }
    self.newConversation = { peerAddress, conversationID in
      let conversation = try await client.conversations.newConversation(with: peerAddress, context: conversationID.build())
      log("Created conversation with Conversation ID and topic: \(conversationID.build()?.conversationID ?? "none"), \(conversation.topic)", level: .info)
      return XMTPConversation.from(conversation)
    }
    self.contacts = { client.contacts }
    self.environment = { client.environment }
  }
}

extension XMTPClient: Equatable {
  public static func == (lhs: XMTPClient, rhs: XMTPClient) -> Bool {
    lhs.address() == rhs.address()
  }
}
