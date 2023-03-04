// Lentil
// Created by Laura and Cordt Zermin

import Dependencies
import Foundation
import IdentifiedCollections


class CacheOld {
  private var publicationsCache: IdentifiedArrayOf<Model.Publication>
  private var profilesCache: IdentifiedArrayOf<Model.Profile>
  private var mediaCache: IdentifiedArrayOf<Model.Media>
  
  static var shared = CacheOld()
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

struct CacheApiOld {
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
  var cacheOld: CacheApiOld {
    get { self[CacheApiOld.self] }
    set { self[CacheApiOld.self] = newValue }
  }
}

extension CacheApiOld: DependencyKey {
  static let liveValue = CacheApiOld(
    publication: CacheOld.shared.publication,
    profileById: { CacheOld.shared.profile($0) },
    profileByAddress: { CacheOld.shared.profile(for: $0) },
    medium: CacheOld.shared.medium,
    updateOrAppendPublication: CacheOld.shared.updateOrAppendPublication,
    updateOrAppendProfile: CacheOld.shared.updateOrAppendProfile,
    updateOrAppendMedia: CacheOld.shared.updateOrAppendMedia,
    clearCache: CacheOld.shared.clearCache
  )
}

#if DEBUG
import XCTestDynamicOverlay

extension CacheApiOld {
  static let previewValue = CacheApiOld(
    publication: { _ in MockData.mockPublications[0] },
    profileById: { _ in MockData.mockProfiles[0] },
    profileByAddress: { _ in MockData.mockProfiles[0] },
    medium: { _ in MockData.mockPublications[0].media.first },
    updateOrAppendPublication: { _ in },
    updateOrAppendProfile: { _ in },
    updateOrAppendMedia: { _ in },
    clearCache: {}
  )
  
  static let testValue = CacheApiOld(
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
