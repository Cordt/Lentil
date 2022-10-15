// Lentil

import ComposableArchitecture
import Foundation
import web3


// MARK: Ethereum Key Storage

fileprivate struct EthereumKeyStorage: EthereumKeyStorageProtocol {
  static private let serviceIdentifier: String = "ethereum-wallet-private-key"
  static private let accountIdentifier: String = "lens-protocol"
  
  let keyStorage = KeyStorage(
    serviceIdentifier: EthereumKeyStorage.serviceIdentifier,
    accountIdentifier: EthereumKeyStorage.accountIdentifier
  )
  
  func storePrivateKey(key: Data) throws {
    try self.keyStorage.storeKey(key: key)
  }
  
  func loadPrivateKey() throws -> Data {
    try self.keyStorage.loadKey()
  }
  
  static func checkForPrivateKey() throws -> Bool {
    try KeyStorage.checkForKey(serviceIdentifier: serviceIdentifier, accountIdentifier: accountIdentifier)
  }
  
  static func deletePrivateKey() throws {
    try KeyStorage.deleteKey(serviceIdentifier: serviceIdentifier, accountIdentifier: accountIdentifier)
  }
}


// MARK: Wallet

protocol Wallet: Equatable {
  var address: String { get }
  var addressShort: String { get }
  var publicKey: String { get }
  
  static func keyStored() throws -> Bool
  static func walletLoaded() throws -> Bool
  static func getWallet() throws -> any Wallet
  static func loadWallet(password: String) throws
  static func createWallet(privateKey: String, password: String) throws
  static func removeWallet() throws -> Void
  
  func sign(message: String) throws -> String
  func sign(message: TypedData) throws -> String
}

extension Wallet {
  var addressShort: String {
    self.address.prefix(4)
    + "..." +
    self.address.suffix(4)
  }
}

class EthereumWallet: Wallet {
  enum Error: Swift.Error, Equatable {
    case keyInvalid
    case noWalletFound
    case walletAlreadyLoaded
    case walletAlreadyStored
    
    case failedToSignMessage
  }
  
  private let storage: EthereumKeyStorage
  private let ethAccount: EthereumAccount
  
  var address: String
  var publicKey: String
  
  private static var shared: EthereumWallet?
  
  static func == (lhs: EthereumWallet, rhs: EthereumWallet) -> Bool {
    lhs.address == rhs.address && lhs.publicKey == rhs.publicKey
  }
  
  // MARK: - Initialiser
  
  private init(password: String) throws {
    self.storage = EthereumKeyStorage()
    self.ethAccount = try EthereumAccount(keyStorage: self.storage, keystorePassword: password)
    self.address = self.ethAccount.address.value
    self.publicKey = self.ethAccount.publicKey
  }
  
  private init(privateKey: String, password: String) throws {
    guard let key = privateKey.web3.hexData
    else { throw Error.keyInvalid }
    
    self.storage = EthereumKeyStorage()
    try self.storage.encryptAndStorePrivateKey(key: key, keystorePassword: password)
    self.ethAccount = try EthereumAccount(keyStorage: self.storage, keystorePassword: password)
    
    self.address = self.ethAccount.address.value
    self.publicKey = self.ethAccount.publicKey
  }
  
  // MARK: - Accessing the singleton
  
  static func keyStored() throws -> Bool {
    try EthereumKeyStorage.checkForPrivateKey()
  }
  
  static func walletLoaded() throws -> Bool {
    return EthereumWallet.shared != nil
  }
  
  static func getWallet() throws -> any Wallet {
    guard let wallet = EthereumWallet.shared
    else { throw Error.noWalletFound }
    
    return wallet
  }
  
  static func loadWallet(password: String) throws {
    if EthereumWallet.shared != nil {
      return
    }
    guard try EthereumKeyStorage.checkForPrivateKey()
    else { throw Error.noWalletFound }
    
    let wallet = try EthereumWallet(password: password)
    EthereumWallet.shared = wallet
  }
  
  static func createWallet(privateKey: String, password: String) throws {
    guard EthereumWallet.shared == nil
    else { throw Error.walletAlreadyLoaded }
    
    guard try !EthereumKeyStorage.checkForPrivateKey()
    else { throw Error.walletAlreadyStored }
    
    let wallet = try EthereumWallet(privateKey: privateKey, password: password)
    EthereumWallet.shared = wallet
  }
  
  static func removeWallet() throws {
    guard EthereumWallet.shared != nil
    else { throw Error.noWalletFound }
    
    try EthereumKeyStorage.deletePrivateKey()
    EthereumWallet.shared = nil
  }
  
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
  var getWallet: () throws -> any Wallet
  var loadWallet: (_ password: String) throws -> ()
  var createWallet: (_ privateKey: String, _ password: String) throws -> ()
  var removeWallet: () throws -> Void
}

extension DependencyValues {
  var walletApi: WalletApi {
    get { self[WalletApi.self] }
    set { self[WalletApi.self] = newValue }
  }
}

extension WalletApi: DependencyKey {
  static var liveValue: WalletApi {
    WalletApi(
      keyStored: EthereumWallet.keyStored,
      walletLoaded: EthereumWallet.walletLoaded,
      getWallet: EthereumWallet.getWallet,
      loadWallet: EthereumWallet.loadWallet,
      createWallet: EthereumWallet.createWallet,
      removeWallet: EthereumWallet.removeWallet
    )
  }
  
  static var previewValue: WalletApi {
    WalletApi(
      keyStored: MockWallet.keyStored,
      walletLoaded: MockWallet.walletLoaded,
      getWallet: MockWallet.getWallet,
      loadWallet: MockWallet.loadWallet,
      createWallet: MockWallet.createWallet,
      removeWallet: MockWallet.removeWallet
    )
  }
}

#if DEBUG
struct MockWallet: Wallet {
  var address: String { ProcessInfo.processInfo.environment["TEST_WALLET_ADDRESS"]! }
  var publicKey: String { ProcessInfo.processInfo.environment["TEST_WALLET_PUBLIC_KEY"]! }
  
  static var shared: MockWallet = MockWallet()
  
  static func keyStored() throws -> Bool { true }
  static func walletLoaded() throws -> Bool { true }
  static func getWallet() throws -> any Wallet { MockWallet.shared }
  static func loadWallet(password: String) throws {}
  static func createWallet(privateKey: String, password: String) throws {}
  static func removeWallet() throws {}
  
  func sign(message: String) throws -> String { "abc-def" }
  func sign(message: TypedData) throws -> String { "def-ghi" }
}
#endif
