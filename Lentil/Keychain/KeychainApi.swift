// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation
import KeychainAccess


protocol KeychainStorable {
  var key: String { get }
}

class KeychainStorage {
  enum KeychainStorageError: Error {
    case couldNotFindItem
  }
  
  static let serviceIdentifier = LentilEnvironment.shared.bundleIdentifier
  static let shared: KeychainStorage = KeychainStorage()
  private let keychain: Keychain
  
  private init() {
    self.keychain = Keychain(service: Self.serviceIdentifier)
  }
  
  func store(string: String, for key: String) throws {
    try self.keychain.set(string, key: key)
  }
  
  func storeData(data: Data, for key: String) throws {
    try self.keychain.set(data, key: key)
  }
  
  func get(for key: String) throws -> String {
    guard let item = try self.keychain.getString(key)
    else { throw KeychainStorageError.couldNotFindItem }
    
    return item
  }
  
  func get(for key: String) throws -> Data {
    guard let item = try self.keychain.getData(key)
    else { throw KeychainStorageError.couldNotFindItem }
    
    return item
  }
  
  func hasStored(for key: String) -> Bool {
    self.keychain[key] != nil
  }
  
  func hasDataStored(for key: String) -> Bool {
    self.keychain[data: key] != nil
  }
  
  func delete(for key: String) throws {
    try self.keychain.remove(key)
  }
}

struct KeychainApi {
  var store: (_ string: String, _ key: String) throws -> Void
  var storeData: (_ data: Data, _ key: String) throws -> Void
  var get: (_ key: String) throws -> String
  var getData: (_ key: String) throws -> Data
  var hasStored: (_ key: String) -> Bool
  var hasDataStored: (_ key: String) -> Bool
  var delete: (_ key: String) throws -> Void
}

extension DependencyValues {
  var keychainApi: KeychainApi {
    get { self[KeychainApi.self] }
    set { self[KeychainApi.self] = newValue }
  }
}

extension KeychainApi: DependencyKey {
  static let liveValue = KeychainApi(
    store: KeychainStorage.shared.store,
    storeData: KeychainStorage.shared.storeData,
    get: KeychainStorage.shared.get,
    getData: KeychainStorage.shared.get,
    hasStored: KeychainStorage.shared.hasStored,
    hasDataStored: KeychainStorage.shared.hasDataStored,
    delete: KeychainStorage.shared.delete
  )
}

#if DEBUG
import XCTestDynamicOverlay

extension KeychainApi {
  static let previewValue = KeychainApi(
    store: { _, _ in () },
    storeData: { _, _ in () },
    get: { _ in "abc-def" },
    getData: { _ in Data() },
    hasStored: { _ in true },
    hasDataStored: { _ in true },
    delete: { _ in () }
  )
  
  static let testValue = KeychainApi(
    store: unimplemented("store"),
    storeData: unimplemented("storeData"),
    get: unimplemented("get"),
    getData: unimplemented("getData"),
    hasStored: unimplemented("hasStored"),
    hasDataStored: unimplemented("hasDataStored"),
    delete: unimplemented("delete")
  )
}
#endif
