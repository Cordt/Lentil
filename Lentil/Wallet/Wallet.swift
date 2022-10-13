// Lentil

import ComposableArchitecture
import Foundation
import web3


// MARK: Key Storage

fileprivate class KeyStorage: EthereumKeyStorageProtocol {
  enum Error: Swift.Error, Equatable {
    case failedToStoreKey
    case failedToLoadKey
    case failedToDeleteKey
  }
  
  static private let serviceIdentifier: String = Bundle.main.bundleIdentifier!
  static private let accountIdentifier: String = "ethereum-private-key"
  
  func storePrivateKey(key: Data) throws {
    do {
      try KeychainInterface.save(
        secret: key,
        service: KeyStorage.serviceIdentifier,
        account: KeyStorage.accountIdentifier
      )
    }
    catch let error {
      print("[ERROR] Failed to save key to keychain: \(error)")
      throw Error.failedToStoreKey
    }
  }
  
  func loadPrivateKey() throws -> Data {
    do {
      return try KeychainInterface.readSecret(
        service: KeyStorage.serviceIdentifier,
        account: KeyStorage.accountIdentifier
      )
    }
    catch let error {
      print("[ERROR] Failed to load key from keychain: \(error)")
      throw Error.failedToLoadKey
    }
  }
  
  static func checkForPrivateKey() throws -> Bool {
    do {
      _ = try KeychainInterface.readSecret(
        service: KeyStorage.serviceIdentifier,
        account: KeyStorage.accountIdentifier
      )
      return true
      
    }
    catch KeychainInterface.KeychainError.itemNotFound {
      return false
    }
  }
  
  static func deletePrivateKey() throws {
    do {
      try KeychainInterface.deleteSecret(
        service: KeyStorage.serviceIdentifier,
        account: KeyStorage.accountIdentifier
      )
    }
    catch let error {
      print("[ERROR] Failed to delete key from keychain: \(error)")
      throw Error.failedToDeleteKey
    }
  }
}


// MARK: Wallet

class Wallet: Equatable {
  enum Error: Swift.Error, Equatable {
    case keyInvalid
    case noWalletFound
    case walletAlreadyLoaded
    case walletAlreadyStored
    
    case failedToSignMessage
  }
  
  private let storage: KeyStorage
  private let ethAccount: EthereumAccount
  
  var address: String
  var publicKey: String
  
  private static var shared: Wallet?
  
  static func == (lhs: Wallet, rhs: Wallet) -> Bool {
    lhs.address == rhs.address && lhs.publicKey == rhs.publicKey
  }
  
  // MARK: - Initialiser
  
  private init(password: String) throws {
    self.storage = KeyStorage()
    self.ethAccount = try EthereumAccount(keyStorage: self.storage, keystorePassword: password)
    self.address = self.ethAccount.address.value
    self.publicKey = self.ethAccount.publicKey
  }
  
  private init(privateKey: String, password: String) throws {
    guard let key = privateKey.web3.hexData
    else { throw Error.keyInvalid }
    
    self.storage = KeyStorage()
    try self.storage.encryptAndStorePrivateKey(key: key, keystorePassword: password)
    self.ethAccount = try EthereumAccount(keyStorage: self.storage, keystorePassword: password)
    
    self.address = self.ethAccount.address.value
    self.publicKey = self.ethAccount.publicKey
  }
  
  // MARK: - Accessing the singleton
  
  static func keyStored() throws -> Bool {
    try KeyStorage.checkForPrivateKey()
  }
  
  static func walletLoaded() throws -> Bool {
    return Wallet.shared != nil
  }
  
  static func getWallet() throws -> Wallet {
    guard let wallet = Wallet.shared
    else { throw Error.noWalletFound }
    
    return wallet
  }
  
  static func loadWallet(password: String) throws -> Wallet {
    if let wallet = Wallet.shared {
      return wallet
    }
    guard try KeyStorage.checkForPrivateKey()
    else { throw Error.noWalletFound }
    
    let wallet = try Wallet(password: password)
    Wallet.shared = wallet
    
    return wallet
  }
  
  static func createWallet(privateKey: String, password: String) throws -> Wallet {
    guard Wallet.shared == nil
    else { throw Error.walletAlreadyLoaded }
    
    guard try !KeyStorage.checkForPrivateKey()
    else { throw Error.walletAlreadyStored }
    
    let wallet = try Wallet(privateKey: privateKey, password: password)
    Wallet.shared = wallet
    
    return wallet
  }
  
  static func removeWallet() throws {
    guard Wallet.shared != nil
    else { throw Error.noWalletFound }
    
    try KeyStorage.deletePrivateKey()
    Wallet.shared = nil
  }
  
  #if DEBUG
  fileprivate static let testWallet = try! Wallet(
    privateKey: ProcessInfo.processInfo.environment["TEST_WALLET_PRIVATE_KEY"]!,
    password: ProcessInfo.processInfo.environment["TEST_WALLET_PASSWORD"]!
  )
  #endif
  
  // MARK: - Methods
  
  func sign(message: String) throws -> String {
    guard let message = message.data(using: .utf8)
    else { throw Error.failedToSignMessage }
    
    do {
      return try self.ethAccount.signMessage(message: message)
    }
    catch let error {
      print("[ERROR] Failed to sign message: \(error)")
      throw Error.failedToSignMessage
    }
    
  }
  
  func sign(message: TypedData) throws -> String {
    do {
      return try self.ethAccount.signMessage(message: message)
    }
    catch let error {
      print("[ERROR] Failed to sign typed data: \(error)")
      throw Error.failedToSignMessage
    }
  }
}


// MARK: Wallet Dependency

struct WalletApi {
  var keyStored: () throws -> Bool
  var walletLoaded: () throws -> Bool
  var getWallet: () throws -> Wallet
  var loadWallet: (_ password: String) throws -> Wallet
  var createWallet: (_ privateKey: String, _ password: String) throws -> Wallet
  var removeWallet: () throws -> Void
}

extension WalletApi: DependencyKey {
  static var liveValue: WalletApi {
    WalletApi(
      keyStored: Wallet.keyStored,
      walletLoaded: Wallet.walletLoaded,
      getWallet: Wallet.getWallet,
      loadWallet: Wallet.loadWallet,
      createWallet: Wallet.createWallet,
      removeWallet: Wallet.removeWallet
    )
  }
}

extension DependencyValues {
  var walletApi: WalletApi {
    get { self[WalletApi.self] }
    set { self[WalletApi.self] = newValue }
  }
}

extension WalletApi {
  static var previewValue: WalletApi {
    WalletApi(
      keyStored: { true },
      walletLoaded: { true },
      getWallet: { Wallet.testWallet },
      loadWallet: { _ in Wallet.testWallet },
      createWallet: { _, _ in Wallet.testWallet },
      removeWallet: {}
    )
  }
}

