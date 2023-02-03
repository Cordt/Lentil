// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import XMTP

class LentilEnvironment {
  let bundleIdentifier: String
  
  let logLevel: LogLevel
  let baseUrl: String
  let origin: String
  
  let xmtpEnvironment: XMTPEnvironment
  
  let infuraUrl: String
  let infuraProjectId: String
  let infuraApiSecretKey: String
  
  let lentilAppId: String
  let lentilIconIPFSUrl: String
  
  let giphyApiKey: String
  
  let sentryDsn: String
  
  #if DEBUG
  let testWalletAddress: String
  #endif
  
  static let shared: LentilEnvironment = LentilEnvironment()
  
  private init() {
    func value(for key: String, addingHttps: Bool = false) -> String {
      let valueString = (Bundle.main.object(forInfoDictionaryKey: key) as? String)!
      return addingHttps ? "https://" + valueString : valueString
    }
    
    self.bundleIdentifier = Bundle.main.bundleIdentifier!
    
    self.logLevel = LogLevel(rawValue: value(for: "LOG_LEVEL").lowercased())!
    self.baseUrl = value(for: "BASE_URL", addingHttps: true)
    self.origin = value(for: "ORIGIN", addingHttps: true)
    
    self.xmtpEnvironment = {
      let env = value(for: "XMTP_ENVIRONMENT")
      if env == "production" { return .production }
      else { return .dev }
    }()
    
    self.infuraUrl = value(for: "INFURA_URL", addingHttps: true)
    self.infuraProjectId = value(for: "INFURA_PROJECT_ID")
    self.infuraApiSecretKey = value(for: "INFURA_API_SECRET_KEY")
    
    self.lentilAppId = "lentil"
    self.lentilIconIPFSUrl = "ipfs://" + value(for: "LENTIL_CID")
    
    self.giphyApiKey = value(for: "GIPHY_API_KEY")
    
    self.sentryDsn = "\(value(for: "SENTRY_DSN_KEY_1"))@\(value(for: "SENTRY_DSN_KEY_2")).ingest.sentry.io/\(value(for: "SENTRY_DSN_PROJECT_ID"))"
    
    #if DEBUG
    self.testWalletAddress = value(for: "TEST_WALLET_ADDRESS")
    #endif
  }
}
