// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import IdentifiedCollections


class Cache {
  private var publicationsCache: IdentifiedArrayOf<Model.Publication>
  private var profilesCache: IdentifiedArrayOf<Model.Profile>
  private var mediaCache: IdentifiedArrayOf<Model.Media>
  private var mediaDataCache: IdentifiedArrayOf<Model.MediaData>
  
  static var shared = Cache()
  private var dataLock: NSLock
  
  private init() {
    self.publicationsCache = []
    self.profilesCache = []
    self.mediaCache = []
    self.mediaDataCache = []
    self.dataLock = NSLock()
  }
  
  func publication(_ for: Model.Publication.ID) -> Model.Publication? {
    self.publicationsCache[id: `for`]
  }
  func profile(_ for: Model.Profile.ID) -> Model.Profile? {
    self.profilesCache[id: `for`]
  }
  func medium(_ for: Model.Media.ID) -> Model.Media? {
    self.mediaCache[id: `for`]
  }
  func mediumData(_ for: Model.MediaData.ID) -> Model.MediaData? {
    dataLock.lock()
    let data = self.mediaDataCache[id: `for`]
    dataLock.unlock()
    return data
  }
  
  func updateOrAppend(_ publication: Model.Publication) {
    self.publicationsCache.updateOrAppend(publication)
  }
  
  func updateOrAppend(_ profile: Model.Profile) {
    self.profilesCache.updateOrAppend(profile)
  }
  
  func updateOrAppend(_ medium: Model.Media) {
    self.mediaCache.updateOrAppend(medium)
  }
  
  func updateOrAppend(_ mediumData: Model.MediaData) {
    dataLock.lock()
    self.mediaDataCache.updateOrAppend(mediumData)
    dataLock.unlock()
  }
  
  func clearCache() {
    self.dataLock.lock()
    self.publicationsCache.removeAll()
    self.profilesCache.removeAll()
    self.mediaCache.removeAll()
    self.mediaDataCache.removeAll()
    self.dataLock.unlock()
  }
}
