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
  
  func store(string: String, for storable: KeychainStorable) throws {
    try self.keychain.set(string, key: storable.key)
  }
  
  func storeData(data: Data, for storable: KeychainStorable) throws {
    try self.keychain.set(data, key: storable.key)
  }
  
  func get(storable: KeychainStorable) throws -> String {
    guard let item = try self.keychain.getString(storable.key)
    else { throw KeychainStorageError.couldNotFindItem }
    
    return item
  }
  
  func getData(storable: KeychainStorable) throws -> Data {
    guard let item = try self.keychain.getData(storable.key)
    else { throw KeychainStorageError.couldNotFindItem }
    
    return item
  }
  
  func checkFor(storable: KeychainStorable) -> Bool {
    self.keychain[storable.key] != nil
  }
  
  func checkForData(storable: KeychainStorable) -> Bool {
    self.keychain[data: storable.key] != nil
  }
  
  func delete(storable: KeychainStorable) throws {
    try self.keychain.remove(storable.key)
  }
}

struct KeychainApi {
  var store: (_ string: String, _ storable: KeychainStorable) throws -> Void
  var storeData: (_ data: Data, _ storable: KeychainStorable) throws -> Void
  var get: (_ storable: KeychainStorable) throws -> String
  var getData: (_ storable: KeychainStorable) throws -> Data
  var checkFor: (_ storable: KeychainStorable) -> Bool
  var checkForData: (_ storable: KeychainStorable) -> Bool
  var delete: (_ storable: KeychainStorable) throws -> Void
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
    getData: KeychainStorage.shared.getData,
    checkFor: KeychainStorage.shared.checkFor,
    checkForData: KeychainStorage.shared.checkForData,
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
    checkFor: { _ in true },
    checkForData: { _ in true },
    delete: { _ in () }
  )
  
  static let testValue = KeychainApi(
    store: unimplemented("store"),
    storeData: unimplemented("storeData"),
    get: unimplemented("load"),
    getData: unimplemented("getData"),
    checkFor: unimplemented("checkFor"),
    checkForData: unimplemented("checkForData"),
    delete: unimplemented("delete")
  )
}
#endif
