// Lentil

import IdentifiedCollections
import Foundation
import XMTP


struct ConversationsLatestRead: DefaultsStorable, Equatable {
  static var profileKey: String { "conversations-latest-read" }
  
  struct LatestReadMessage: Codable, Equatable, Identifiable {
    var id: String { Self.buildID(peerAddress: self.peerAddress, conversationID: self.conversationID) }
    var peerAddress: String
    var conversationID: String?
    var lastSent: Date?
    
    init(message: XMTP.DecodedMessage, conversationID: String?) {
      self.peerAddress = message.senderAddress
      self.conversationID = conversationID
      self.lastSent = message.sent
    }
    
    static func buildID(peerAddress: String, conversationID: String?) -> Self.ID {
      peerAddress + (conversationID != nil ? "-\(conversationID!)" : "")
    }
  }
  
  var latestReadMessages: IdentifiedArrayOf<LatestReadMessage>
  
  func latestReadMessageDate(from conversation: XMTPConversation) -> Date? {
    let id = LatestReadMessage.buildID(peerAddress: conversation.peerAddress, conversationID: conversation.conversationID)
    guard let latestReadMessage = self.latestReadMessages[id: id]
    else { return nil }
    
    return latestReadMessage.lastSent
  }
  
  mutating func updateLatestReadMessageDate(for conversation: XMTPConversation, with date: Date) {
    let id = LatestReadMessage.buildID(peerAddress: conversation.peerAddress, conversationID: conversation.conversationID)
    self.latestReadMessages[id: id]?.lastSent = date
  }
}
