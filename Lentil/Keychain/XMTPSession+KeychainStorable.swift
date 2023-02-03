// Lentil


enum XMTPSession: KeychainStorable {
  case current
  
  var key: String { "xmtp-user-keys" }
}
