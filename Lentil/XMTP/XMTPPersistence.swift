// Lentil

import Foundation
import KeychainAccess
import XMTP


struct XMTPPersistence {
  var keychain: Keychain
  
  init() {
    keychain = Keychain(service: "com.xmtp.XMTPiOSExample")
  }
  
  func saveKeys(_ keys: Data) {
    keychain[data: "keys"] = keys
  }
  
  func loadKeys() -> Data? {
    do {
      return try keychain.getData("keys")
    } catch {
      print("Error loading keys data: \(error)")
      return nil
    }
  }
  
  func load(conversationTopic: String) throws -> XMTP.ConversationContainer? {
    guard let data = try keychain.getData(key(topic: conversationTopic)) else {
      return nil
    }
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ConversationContainer.self, from: data)
    
    return decoded
  }
  
  func save(conversation: XMTP.Conversation) throws {
    keychain[data: key(topic: conversation.topic)] = try JSONEncoder().encode(conversation.encodedContainer)
  }
  
  func key(topic: String) -> String {
    "conversation-\(topic)"
  }
}
