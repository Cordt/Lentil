// Lentil
// Created by Laura and Cordt Zermin

import Foundation

class LentilEnvironment {
  let logLevel: LogLevel
  let baseUrl: String
  let origin: String
  
  let infuraUrl: String
  let infuraProjectId: String
  let infuraApiSecretKey: String
  
  #if DEBUG
  let testWalletAddress: String
  #endif
  
  static let shared: LentilEnvironment = LentilEnvironment()
  
  private init() {
    func value(for key: String, addingHttps: Bool = false) -> String {
      let valueString = (Bundle.main.object(forInfoDictionaryKey: key) as? String)!
      return addingHttps ? "https://" + valueString : valueString
    }
    
    self.logLevel = LogLevel(rawValue: value(for: "LOG_LEVEL").lowercased())!
    self.baseUrl = value(for: "BASE_URL", addingHttps: true)
    self.origin = value(for: "ORIGIN", addingHttps: true)
    
    self.infuraUrl = value(for: "INFURA_URL", addingHttps: true)
    self.infuraProjectId = value(for: "INFURA_PROJECT_ID")
    self.infuraApiSecretKey = value(for: "INFURA_API_SECRET_KEY")
    
    #if DEBUG
    self.testWalletAddress = value(for: "TEST_WALLET_ADDRESS")
    #endif
  }
}
