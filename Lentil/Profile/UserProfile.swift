// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation


struct UserProfile: Codable, Equatable {
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
  
  static func load() -> UserProfile? {
    guard let encodedProfile = UserDefaults.standard.object(forKey: self.profileKey) as? Data
    else { return nil }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(UserProfile.self, from: encodedProfile)
    } catch let error {
      log("Failed to decode User Profile from defaults", level: .error, error: error)
      return nil
    }
  }
  
  static func remove() {
    UserDefaults.standard.removeObject(forKey: self.profileKey)
  }
}

struct ProfileStorageApi {
  var store: (_ profile: UserProfile) throws -> Void
  var load: () -> UserProfile?
  var remove: () -> Void
}

extension DependencyValues {
  var profileStorageApi: ProfileStorageApi {
    get { self[ProfileStorageApi.self] }
    set { self[ProfileStorageApi.self] = newValue }
  }
}

extension ProfileStorageApi: DependencyKey {
  static let liveValue = ProfileStorageApi(
    store: ProfileStorage.store,
    load: ProfileStorage.load,
    remove: ProfileStorage.remove
  )
}



#if DEBUG
import XCTestDynamicOverlay

extension ProfileStorageApi {
  static let previewValue = ProfileStorageApi(
    store: { _ in },
    load: { MockData.mockUserProfile },
    remove: {}
  )
  
  static let testValue = ProfileStorageApi(
    store: unimplemented("store"),
    load: unimplemented("load"),
    remove: unimplemented("remove")
  )
}

extension MockData {
  static var mockUserProfile: UserProfile {
    UserProfile(
      id: "3",
      handle: "cordt.lens",
      name: "Cordt",
      address: LentilEnvironment.shared.testWalletAddress
    )
  }
}
#endif
