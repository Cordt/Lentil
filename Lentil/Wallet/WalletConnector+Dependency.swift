// Lentil

import Dependencies
import Foundation


extension WalletConnectorApi: DependencyKey {
  static var liveValue: WalletConnectorApi {
    WalletConnectorApi(
      connect: WalletConnector.shared.connect,
      disconnect: WalletConnector.shared.disconnect,
      personalSign: WalletConnector.shared.personalSign(message:),
      personalSignData: WalletConnector.shared.personalSign(data:)
    )
  }
}

extension DependencyValues {
  var walletConnect: WalletConnectorApi {
    get { self[WalletConnectorApi.self] }
    set { self[WalletConnectorApi.self] = newValue }
  }
}

struct WalletConnectorApi {
  var connect: () async throws -> String
  var disconnect: () async throws -> Void
  var personalSign: (_ message: String) async throws -> String
  var personalSignData: (_ data: Data) async throws -> Data
}
