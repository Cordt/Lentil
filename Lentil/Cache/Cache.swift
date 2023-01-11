// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation
import IdentifiedCollections


class Cache {
  private var publicationsCache: IdentifiedArrayOf<Model.Publication>
  private var profilesCache: IdentifiedArrayOf<Model.Profile>
  private var mediaCache: IdentifiedArrayOf<Model.Media>
  
  static var shared = Cache()
  private var dataLock: NSLock
  
  private init() {
    self.publicationsCache = []
    self.profilesCache = []
    self.mediaCache = []
    self.dataLock = NSLock()
  }
  
  func publication(_ for: Model.Publication.ID) -> Model.Publication? {
    self.publicationsCache[id: `for`]
  }
  func profile(_ for: Model.Profile.ID) -> Model.Profile? {
    self.profilesCache[id: `for`]
  }
  func profile(for address: String) -> Model.Profile? {
    self.profilesCache.first { $0.ownedBy == address }
  }
  func medium(_ for: Model.Media.ID) -> Model.Media? {
    self.mediaCache[id: `for`]
  }
  
  func updateOrAppendPublication(_ publication: Model.Publication) {
    self.publicationsCache.updateOrAppend(publication)
  }
  
  func updateOrAppendProfile(_ profile: Model.Profile) {
    self.profilesCache.updateOrAppend(profile)
  }
  
  func updateOrAppendMedia(_ medium: Model.Media) {
    dataLock.lock()
    self.mediaCache.updateOrAppend(medium)
    dataLock.unlock()
  }
  
  func clearCache() {
    self.dataLock.lock()
    self.publicationsCache.removeAll()
    self.profilesCache.removeAll()
    self.mediaCache.removeAll()
    self.dataLock.unlock()
  }
}

struct CacheApi {
  var publication: (_ for: Model.Publication.ID) -> Model.Publication?
  var profileById: (Model.Profile.ID) -> Model.Profile?
  var profileByAddress: (String) -> Model.Profile?
  var medium: (_ for: Model.Media.ID) -> Model.Media?
  var updateOrAppendPublication: (_ publication: Model.Publication) -> Void
  var updateOrAppendProfile: (_ profile: Model.Profile) -> Void
  var updateOrAppendMedia: (_ medium: Model.Media) -> Void
  var clearCache: () -> Void
}

extension DependencyValues {
  var cache: CacheApi {
    get { self[CacheApi.self] }
    set { self[CacheApi.self] = newValue }
  }
}

extension CacheApi: DependencyKey {
  static let liveValue = CacheApi(
    publication: Cache.shared.publication,
    profileById: { Cache.shared.profile($0) },
    profileByAddress: { Cache.shared.profile(for: $0) },
    medium: Cache.shared.medium,
    updateOrAppendPublication: Cache.shared.updateOrAppendPublication,
    updateOrAppendProfile: Cache.shared.updateOrAppendProfile,
    updateOrAppendMedia: Cache.shared.updateOrAppendMedia,
    clearCache: Cache.shared.clearCache
  )
}

#if DEBUG
import XCTestDynamicOverlay

extension CacheApi {
  static let previewValue = CacheApi(
    publication: { _ in MockData.mockPublications[0] },
    profileById: { _ in MockData.mockProfiles[0] },
    profileByAddress: { _ in MockData.mockProfiles[0] },
    medium: { _ in MockData.mockPublications[0].media.first },
    updateOrAppendPublication: { _ in },
    updateOrAppendProfile: { _ in },
    updateOrAppendMedia: { _ in },
    clearCache: {}
  )
  
  static let testValue = CacheApi(
    publication: unimplemented("publication"),
    profileById: unimplemented("profileById"),
    profileByAddress: unimplemented("profileByAddress"),
    medium: unimplemented("medium"),
    updateOrAppendPublication: unimplemented("updateOrAppendPublication"),
    updateOrAppendProfile: unimplemented("updateOrAppendProfile"),
    updateOrAppendMedia: unimplemented("updateOrAppendMedia"),
    clearCache: unimplemented("clearCache")
  )
}
#endif
