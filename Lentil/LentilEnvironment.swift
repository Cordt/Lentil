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
    #if DEBUG
    self.logLevel = LogLevel(rawValue: ProcessInfo.processInfo.environment["LOG_LEVEL"]!.lowercased())!
    self.baseUrl = ProcessInfo.processInfo.environment["BASE_URL"]!
    self.origin = ProcessInfo.processInfo.environment["ORIGIN"]!
    self.testWalletAddress = ProcessInfo.processInfo.environment["TEST_WALLET_ADDRESS"]!
    #else
    self.logLevel = .error
    self.baseUrl = "https://api.lens.dev"
    self.origin = "https://lentilapp.xyz"
    #endif
    
    self.infuraUrl = "https://ipfs.infura.io:5001/api/v0/add"
    self.infuraProjectId = (Bundle.main.object(forInfoDictionaryKey: "INFURA_PROJECT_ID") as? String)!
    self.infuraApiSecretKey = (Bundle.main.object(forInfoDictionaryKey: "INFURA_API_SECRET_KEY") as? String)!
    
  }
}
