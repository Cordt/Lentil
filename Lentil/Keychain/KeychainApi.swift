// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation
import KeychainAccess


protocol KeychainStorable {
  var key: String { get }
}

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
  
  func get(storable: KeychainStorable) throws -> String {
    guard let item = try self.keychain.getString(storable.key)
    else { throw KeychainStorageError.couldNotFindItem }
    
    return item
  }
  
  func checkFor(storable: KeychainStorable) -> Bool {
    self.keychain[string: storable.key] != nil
  }
  
  func delete(storable: KeychainStorable) throws {
    try self.keychain.remove(storable.key)
  }
}

struct KeychainApi {
  var store: (_ string: String, _ storable: KeychainStorable) throws -> Void
  var get: (_ storable: KeychainStorable) throws -> String
  var checkFor: (_ storable: KeychainStorable) -> Bool
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
    get: KeychainStorage.shared.get,
    checkFor: KeychainStorage.shared.checkFor,
    delete: KeychainStorage.shared.delete
  )
}

#if DEBUG
import XCTestDynamicOverlay

extension KeychainApi {
  static let previewValue = KeychainApi(
    store: { _, _ in () },
    get: { _ in "abc-def" },
    checkFor: { _ in true },
    delete: { _ in () }
  )
  
  static let testValue = KeychainApi(
    store: unimplemented("store"),
    get: unimplemented("load"),
    checkFor: unimplemented("checkFor"),
    delete: unimplemented("delete")
  )
}
#endif
