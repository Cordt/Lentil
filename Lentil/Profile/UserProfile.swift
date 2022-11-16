// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation


struct UserProfile: Codable {
  var id: String
  var handle: String
  var name: String?
  var address: String
}

class ProfileStorage {
  private static let profileKey = "user-profile"
  
  static func store(profile: UserProfile) throws {
    let encoder = JSONEncoder()
    let encodedProfile = try encoder.encode(profile)
    UserDefaults.standard.set(encodedProfile, forKey: self.profileKey)
  }
  
  static func load() throws -> UserProfile? {
    guard let encodedProfile = UserDefaults.standard.object(forKey: self.profileKey) as? Data
    else { return nil }
    
    let decoder = JSONDecoder()
    return try decoder.decode(UserProfile.self, from: encodedProfile)
  }
  
  static func remove() {
    UserDefaults.standard.removeObject(forKey: self.profileKey)
  }
}

struct ProfileStorageApi {
  var store: (_ profile: UserProfile) throws -> Void
  var load: () throws -> UserProfile?
  var remove: () -> Void
}

extension ProfileStorageApi: DependencyKey {
  static let liveValue = ProfileStorageApi(
    store: ProfileStorage.store,
    load: ProfileStorage.load,
    remove: ProfileStorage.remove
  )
  
  static let previewValue = ProfileStorageApi(
    store: { _ in },
    load: { mockUserProfile },
    remove: {}
  )
}

extension DependencyValues {
  var profileStorageApi: ProfileStorageApi {
    get { self[ProfileStorageApi.self] }
    set { self[ProfileStorageApi.self] = newValue }
  }
}


#if DEBUG
var mockUserProfile = UserProfile(
  id: "3",
  handle: "@cordt.lens",
  name: "Cordt",
  address: ProcessInfo.processInfo.environment["TEST_WALLET_PUBLIC_KEY"]!
)
#endif
