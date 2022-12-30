// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import XMTP


class XMTPClient {
  private var client: XMTP.Client
  
  var address: () -> String
  var conversations: () -> XMTP.Conversations
  var contacts: () -> XMTP.Contacts
  var environment: () -> XMTPEnvironment
  
  init(account: SigningKey, options: ClientOptions? = nil) async throws {
    let client = try await XMTP.Client.create(account: account, options: options)
    
    self.client = client
    self.address = { client.address }
    self.conversations = { client.conversations }
    self.contacts = { client.contacts }
    self.environment = { client.environment }
  }
}

extension XMTPClient: Equatable {
  public static func == (lhs: XMTPClient, rhs: XMTPClient) -> Bool {
    lhs.address() == rhs.address()
  }
}
