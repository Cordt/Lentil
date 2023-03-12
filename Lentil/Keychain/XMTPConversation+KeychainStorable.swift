// Lentil

import XMTP


extension XMTPConversation: KeychainStorable {
  var key: String { "xmtp-conversation-" + self.topic }
}

struct XMTPConversations: KeychainStorable, Codable {
  var key: String { "xmtp-conversation-ids" }
  var ids: Set<String> = .init()
}
