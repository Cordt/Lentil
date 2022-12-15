// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation


class AuthTokenStorage {
  enum Error: Swift.Error {
    case encodingError
    case decodingError
  }
  
  enum Token {
    case access
    case refresh
    
    var serviceIdentifier: String {
      switch self {
        case .access:
          return "access-token"
        case .refresh:
          return "refresh-token"
      }
    }
    var accountIdentifier: String {
      switch self {
        case .access:
          return "lens-protocol"
        case .refresh:
          return "lens-protocol"
      }
    }
    var storage: KeyStorage {
      switch self {
        case .access:
          return AuthTokenStorage.accessTokenStorage
        case .refresh:
          return AuthTokenStorage.refreshTokenStorage
      }
    }
  }
  
  private static let accessTokenStorage = KeyStorage(
    serviceIdentifier: Token.access.serviceIdentifier,
    accountIdentifier: Token.access.accountIdentifier
  )
  
  private static let refreshTokenStorage = KeyStorage(
    serviceIdentifier: Token.refresh.serviceIdentifier,
    accountIdentifier: Token.refresh.accountIdentifier
  )
  
  static func store(token: Token, key: String) throws {
    guard let keyData = key.data(using: .utf8)
    else { throw Error.encodingError }
    try token.storage.storeKey(key: keyData)
  }
  
  static func load(token: Token) throws -> String {
    let keyData = try token.storage.loadKey()
    guard let key = String(data: keyData, encoding: .utf8)
    else { throw Error.decodingError }
    return key
  }
  
  static func checkFor(token: Token) throws -> Bool {
    try KeyStorage.checkForKey(serviceIdentifier: token.serviceIdentifier, accountIdentifier: token.accountIdentifier)
  }
  
  static func delete() throws {
    try KeyStorage.deleteKey(
      serviceIdentifier: Token.access.serviceIdentifier,
      accountIdentifier: Token.access.accountIdentifier
    )
    try KeyStorage.deleteKey(
      serviceIdentifier: Token.refresh.serviceIdentifier,
      accountIdentifier: Token.refresh.accountIdentifier
    )
  }
}

struct AuthTokenApi {
  var store: (_ token: AuthTokenStorage.Token, _ key: String) throws -> Void
  var load: (_ token: AuthTokenStorage.Token) throws -> String
  var checkFor: (_ token: AuthTokenStorage.Token) throws -> Bool
  var delete: () throws -> Void
}

extension DependencyValues {
  var authTokenApi: AuthTokenApi {
    get { self[AuthTokenApi.self] }
    set { self[AuthTokenApi.self] = newValue }
  }
}

extension AuthTokenApi: DependencyKey {
  static let liveValue = AuthTokenApi(
    store: AuthTokenStorage.store,
    load: AuthTokenStorage.load,
    checkFor: AuthTokenStorage.checkFor,
    delete: AuthTokenStorage.delete
  )
}

#if DEBUG
extension AuthTokenApi {
  static let previewValue = AuthTokenApi(
    store: { _, _ in () },
    load: { _ in "abc-def" },
    checkFor: { _ in true },
    delete: { () }
  )
}
#endif
