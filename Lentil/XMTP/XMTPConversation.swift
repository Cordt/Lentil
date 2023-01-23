// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import XMTP

extension XMTP.DecodedMessage {
  var bodyText: String {
    return try! self.content()
  }
}


struct XMTPConversation: Hashable, Equatable, Identifiable {
  var id: String { self.peerAddress }
  var peerAddress: String
  var shortenedAddress: String { String(self.peerAddress[0..<4] + "..." + self.peerAddress[self.peerAddress.count - 4..<self.peerAddress.count]) }
  var conversationID: String?
  var send: (_ text: String) async throws -> Void
  var topic: String
  var streamMessages: () -> AsyncThrowingStream<DecodedMessage, Error>
  var messages: () async throws -> [DecodedMessage]
  var hash: (_ hasher: inout Hasher) -> Void
  
  func hash(into hasher: inout Hasher) { self.hash(&hasher) }
  
  static func == (lhs: XMTPConversation, rhs: XMTPConversation) -> Bool {
    lhs.id == rhs.id && lhs.conversationID == rhs.conversationID
  }
  
  static func from(_ conversation: XMTP.Conversation) -> Self {
    .init(
      peerAddress: conversation.peerAddress,
      conversationID: conversation.conversationID,
      send: { try await conversation.send(text: $0) },
      topic: conversation.topic,
      streamMessages: conversation.streamMessages,
      messages: { try await conversation.messages() },
      hash: conversation.hash(into:)
    )
  }
}

#if DEBUG
extension MockData {
  static var conversations: [XMTPConversation] {
    [
      XMTPConversation(
        peerAddress: "0x123abcdef",
        send: { _ in },
        topic: "TOPIC_abc",
        streamMessages: { AsyncThrowingStream(unfolding: { nil })},
        messages: { MockData.messages },
        hash: { _ in }
      ),
      XMTPConversation(
        peerAddress: "0xabc123def",
        send: { _ in },
        topic: "TOPIC_def",
        streamMessages: { AsyncThrowingStream(unfolding: { nil })},
        messages: { MockData.messages },
        hash: { _ in }
      ),
      XMTPConversation(
        peerAddress: "0x123abc456",
        send: { _ in },
        topic: "TOPIC_ghi",
        streamMessages: { AsyncThrowingStream(unfolding: { nil })},
        messages: { MockData.messages },
        hash: { _ in }
      )
    ]
  }
}
#endif
