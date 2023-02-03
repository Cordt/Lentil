// Lentil


enum AccessToken: KeychainStorable {
  case access
  case refresh
  
  var key: String {
    switch self {
      case .access:
        return "lens-access-token"
      case .refresh:
        return "lens-refresh-token"
    }
  }
}
