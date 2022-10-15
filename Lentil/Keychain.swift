// Lentil
// Taken from https://www.advancedswift.com/secure-private-data-keychain-swift/

import Foundation


struct KeychainInterface {
  enum KeychainError: Error {
    // Attempted read for an item that does not exist.
    case itemNotFound
    
    // Attempted save to override an existing item.
    // Use update instead of save to update existing items
    case duplicateItem
    
    // A read of an item in any format other than Data
    case invalidItemFormat
    
    // Any operation result status than errSecSuccess
    case unexpectedStatus(OSStatus)
  }
  
  static func readSecret(service: String, account: String) throws -> Data {
    let query: [String: AnyObject] = [
      // kSecAttrService,  kSecAttrAccount, and kSecClass
      // uniquely identify the item to read in Keychain
      kSecAttrService as String: service as AnyObject,
      kSecAttrAccount as String: account as AnyObject,
      kSecClass as String: kSecClassGenericPassword,
      
      // kSecMatchLimitOne indicates keychain should read
      // only the most recent item matching this query
      kSecMatchLimit as String: kSecMatchLimitOne,
      
      // kSecReturnData is set to kCFBooleanTrue in order
      // to retrieve the data for the item
      kSecReturnData as String: kCFBooleanTrue,
      
      // kSecAttrSynchronizable is set to kCFBooleanTrue
      // in order to sync this item via iCloud, if available
      kSecAttrSynchronizable as String: kCFBooleanFalse
    ]
    
    // SecItemCopyMatching will attempt to copy the item
    // identified by query to the reference itemCopy
    var itemCopy: AnyObject?
    let status = SecItemCopyMatching(
      query as CFDictionary,
      &itemCopy
    )
    
    // errSecItemNotFound is a special status indicating the
    // read item does not exist. Throw itemNotFound so the
    // client can determine whether or not to handle
    // this case
    guard status != errSecItemNotFound else {
      throw KeychainError.itemNotFound
    }
    
    // Any status other than errSecSuccess indicates the
    // read operation failed.
    guard status == errSecSuccess else {
      throw KeychainError.unexpectedStatus(status)
    }
    
    // This implementation of KeychainInterface requires all
    // items to be saved and read as Data. Otherwise,
    // invalidItemFormat is thrown
    guard let secret = itemCopy as? Data else {
      throw KeychainError.invalidItemFormat
    }
    
    return secret
  }
  
  static func save(secret: Data, service: String, account: String) throws {
    let query: [String: AnyObject] = [
      // kSecAttrService,  kSecAttrAccount, and kSecClass
      // uniquely identify the item to save in Keychain
      kSecAttrService as String: service as AnyObject,
      kSecAttrAccount as String: account as AnyObject,
      kSecClass as String: kSecClassGenericPassword,
      
      // kSecValueData is the item value to save
      kSecValueData as String: secret as AnyObject,
      
      // kSecAttrSynchronizable is set to kCFBooleanTrue
      // in order to sync this item via iCloud, if available
      kSecAttrSynchronizable as String: kCFBooleanFalse
    ]
    
    // SecItemAdd attempts to add the item identified by
    // the query to keychain
    let status = SecItemAdd(
      query as CFDictionary,
      nil
    )
    
    // errSecDuplicateItem is a special case where the
    // item identified by the query already exists. Throw
    // duplicateItem so the client can determine whether
    // or not to handle this as an error
    if status == errSecDuplicateItem {
      throw KeychainError.duplicateItem
    }
    
    // Any status other than errSecSuccess indicates the
    // save operation failed.
    guard status == errSecSuccess else {
      throw KeychainError.unexpectedStatus(status)
    }
  }
  
  static func deleteSecret(service: String, account: String) throws {
    let query: [String: AnyObject] = [
      // kSecAttrService,  kSecAttrAccount, and kSecClass
      // uniquely identify the item to delete in Keychain
      kSecAttrService as String: service as AnyObject,
      kSecAttrAccount as String: account as AnyObject,
      kSecClass as String: kSecClassGenericPassword
    ]
    
    // SecItemDelete attempts to perform a delete operation
    // for the item identified by query. The status indicates
    // if the operation succeeded or failed.
    let status = SecItemDelete(query as CFDictionary)
    
    // Any status other than errSecSuccess indicates the
    // delete operation failed.
    guard status == errSecSuccess else {
      throw KeychainError.unexpectedStatus(status)
    }
  }
}

struct KeyStorage {
  enum Error: Swift.Error, Equatable {
    case failedToStoreKey
    case failedToLoadKey
    case failedToDeleteKey
  }
  
  private(set) var serviceIdentifier: String
  private(set) var accountIdentifier: String
  
  func storeKey(key: Data) throws {
    do {
      try KeychainInterface.save(
        secret: key,
        service: self.serviceIdentifier,
        account: self.accountIdentifier
      )
    }
    catch let error {
      print("[ERROR] Failed to save key to keychain: \(error)")
      throw Error.failedToStoreKey
    }
  }
  
  func loadKey() throws -> Data {
    do {
      return try KeychainInterface.readSecret(
        service: self.serviceIdentifier,
        account: self.accountIdentifier
      )
    }
    catch let error {
      print("[ERROR] Failed to load key from keychain: \(error)")
      throw Error.failedToLoadKey
    }
  }
  
  static func checkForKey(serviceIdentifier: String, accountIdentifier: String) throws -> Bool {
    do {
      _ = try KeychainInterface.readSecret(
        service: serviceIdentifier,
        account: accountIdentifier
      )
      return true
      
    }
    catch KeychainInterface.KeychainError.itemNotFound {
      return false
    }
  }
  
  static func deleteKey(serviceIdentifier: String, accountIdentifier: String) throws {
    do {
      try KeychainInterface.deleteSecret(
        service: serviceIdentifier,
        account: accountIdentifier
      )
    }
    catch let error {
      print("[ERROR] Failed to delete key from keychain: \(error)")
      throw Error.failedToDeleteKey
    }
  }
}
