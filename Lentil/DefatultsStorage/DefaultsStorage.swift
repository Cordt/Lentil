// Lentil

import Foundation
import Dependencies


protocol DefaultsStorable: Codable {
  static var profileKey: String { get }
}

struct DefaultsStorage {
  static func store(item: DefaultsStorable, for key: String) throws {
    let encoder = JSONEncoder()
    let encodedItem = try encoder.encode(item)
    UserDefaults.standard.set(encodedItem, forKey: key)
  }
  
  static func load<Item: DefaultsStorable>(item: Item.Type) -> Item? {
    guard let encodedItem = UserDefaults.standard.object(forKey: Item.profileKey) as? Data
    else { return nil }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(item.self, from: encodedItem)
    } catch let error {
      log("Failed to decode Item of type \(item) from defaults", level: .error, error: error)
      return nil
    }
  }
  
  static func remove(for key: String) {
    UserDefaults.standard.removeObject(forKey: key)
  }
}

struct DefaultsStorageApi {
  var store: (_ item: DefaultsStorable) throws -> Void
  var load: (_ item: DefaultsStorable.Type) -> (any DefaultsStorable)?
  var remove: (_ item: DefaultsStorable.Type) -> Void
}

extension DependencyValues {
  var defaultsStorageApi: DefaultsStorageApi {
    get { self[DefaultsStorageApi.self] }
    set { self[DefaultsStorageApi.self] = newValue }
  }
}

extension DefaultsStorageApi: DependencyKey {
  static let liveValue = DefaultsStorageApi(
    store: { try DefaultsStorage.store(item: $0, for: type(of: $0).profileKey) },
    load: { DefaultsStorage.load(item: $0) },
    remove: { DefaultsStorage.remove(for: $0.profileKey) }
  )
}


#if DEBUG
import XCTestDynamicOverlay

extension DefaultsStorageApi {
  static let previewValue = DefaultsStorageApi(
    store: { _ in },
    load: { itemType in
      if itemType == UserProfile.self { return MockData.mockUserProfile }
      else { return nil }
    },
    remove: { _ in }
  )
  
  static let testValue = DefaultsStorageApi(
    store: unimplemented("store"),
    load: unimplemented("load"),
    remove: unimplemented("remove")
  )
}
#endif
