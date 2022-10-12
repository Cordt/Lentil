// Lentil

import ComposableArchitecture
import Foundation
import web3


enum WalletError: Error, Equatable {
  case failedToStoreKey
  case noAccountSetup
  case invalidKey
  case invalidMessage
}


// MARK: Storage

fileprivate class KeyStorage: EthereumKeyStorageProtocol {
  static private let serviceIdentifier: String = Bundle.main.bundleIdentifier!
  static private let accountIdentifier: String = "ethereum-private-key"
  
  func storePrivateKey(key: Data) throws {
    do {
      
      try KeychainInterface.save(
        secret: key,
        service: KeyStorage.serviceIdentifier,
        account: KeyStorage.accountIdentifier
      )
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  func loadPrivateKey() throws -> Data {
    return try KeychainInterface.readSecret(
      service: KeyStorage.serviceIdentifier,
      account: KeyStorage.accountIdentifier
    )
  }
  
  static func checkForPrivateKey() throws -> Bool {
    do {
      _ = try KeychainInterface.readSecret(
        service: KeyStorage.serviceIdentifier,
        account: KeyStorage.accountIdentifier
      )
      return true
      
    } catch KeychainInterface.KeychainError.itemNotFound {
      return false
    }
  }
  
  static func deletePrivateKey() throws {
    try KeychainInterface.deleteSecret(
      service: KeyStorage.serviceIdentifier,
      account: KeyStorage.accountIdentifier
    )
  }
}


// MARK: Wallet

class Wallet: Equatable {
  private let storage: KeyStorage
  private let ethAccount: EthereumAccount
  
  var address: String
  var publicKey: String
  
  static func == (lhs: Wallet, rhs: Wallet) -> Bool {
    lhs.address == rhs.address && lhs.publicKey == rhs.publicKey
  }
  
  init(password: String) throws {
    self.storage = KeyStorage()
    self.ethAccount = try EthereumAccount(keyStorage: self.storage, keystorePassword: password)
    self.address = self.ethAccount.address.value
    self.publicKey = self.ethAccount.publicKey
  }
  
  init(privateKey: String, password: String) throws {
    guard let key = privateKey.web3.hexData
    else { throw WalletError.invalidKey }
    
    self.storage = KeyStorage()
    try self.storage.encryptAndStorePrivateKey(key: key, keystorePassword: password)
    self.ethAccount = try EthereumAccount(keyStorage: self.storage, keystorePassword: password)
    
    self.address = self.ethAccount.address.value
    self.publicKey = self.ethAccount.publicKey
  }
  
  func sign(message: String) throws -> String {
    guard let message = message.data(using: .utf8)
    else { throw WalletError.invalidMessage }
    
    return try self.ethAccount.signMessage(message: message)
  }
  
  func sign(message: TypedData) throws -> String {
    return try self.ethAccount.signMessage(message: message)
  }
  
  static func hasAccount() throws -> Bool {
    try KeyStorage.checkForPrivateKey()
  }
  
  static func removeAccount() throws {
    try KeyStorage.deletePrivateKey()
  }
}

// MARK: Wallet Dependency

struct WalletApi {
  var walletExists: () throws -> Bool
  var fetchWallet: (_ password: String) throws -> Wallet
  var createWallet: (_ privateKey: String, _ password: String) throws -> Wallet
}

extension WalletApi: DependencyKey {
  static var liveValue: WalletApi {
    WalletApi(
      walletExists: Wallet.hasAccount,
      fetchWallet: Wallet.init,
      createWallet: Wallet.init
    )
  }
  
  static var previewValue: WalletApi {
    WalletApi(
      walletExists: { true },
      fetchWallet: { _ in testWallet },
      createWallet: { _, _ in testWallet }
    )
  }
}

extension DependencyValues {
  var walletApi: WalletApi {
    get { self[WalletApi.self] }
    set { self[WalletApi.self] = newValue }
  }
}

#if DEBUG
let testWallet = try! Wallet(
  privateKey: ProcessInfo.processInfo.environment["TEST_WALLET_PRIVATE_KEY"]!,
  password: ProcessInfo.processInfo.environment["TEST_WALLET_PASSWORD"]!
)
#endif

