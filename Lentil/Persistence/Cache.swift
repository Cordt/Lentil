// Lentil

import Asynchrone
import Dependencies
import Foundation
import IdentifiedCollections
import RealmSwift


class Cache {
  enum UpdateType {
    case addReaction(userProfileId: String)
    case removeReaction(userProfileId: String)
  }
  
  static let shared = Cache()
  static let realmConfig = Realm.Configuration(inMemoryIdentifier: LentilEnvironment.shared.memoryRealmIdentifier)
  
  private var realmReference: Realm
  private var exploreCursor: Cursor
  private var feedCursor: Cursor
  private var notificationsCursor: Cursor
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.infuraApi) var infuraApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.uuid) var uuid
  
  private init() {
    self.realmReference = try! Realm(configuration: Self.realmConfig)
    self.exploreCursor = .init()
    self.feedCursor = .init()
    self.notificationsCursor = .init()
  }
  
  
  // MARK: Read and load single Elements
  
  func profile(by id: String) async throws -> Model.Profile? {
    try await self.fetchElement(
      primaryKey: id,
      transformToViewModel: { $0.profile() },
      transformToCacheModel: { $0.realmProfile() },
      fetch: { try await self.lensApi.profile(id) }
    )
  }
  
  func profileBy(address: String) async throws -> Model.Profile? {
    try await self.fetchElement(
      where: { $0.ownedBy == address },
      transformToViewModel: { $0.profile() },
      transformToCacheModel: { $0.realmProfile() },
      fetch: { nil }
    )
  }
  
  func publication(for id: String) async throws -> Model.Publication? {
    try await self.fetchElement(
      primaryKey: id,
      transformToViewModel: { $0.publication() },
      transformToCacheModel: { $0.realmPublication() },
      fetch: { try await self.lensApi.publicationById(id) }
    )
  }
  
  
  // MARK: Read and load collections of Elements
  
  func comments(of publication: Model.Publication, for userId: String? = nil) async throws -> [Model.Publication] {
    try await self.fetchElements(
      where: { $0.parentPublication.id == publication.id },
      transformToViewModel: { $0.publication() },
      transformToCacheModel: { $0.realmPublication() },
      fetch: { try await self.lensApi.commentsOfPublication(publication, userId).data }
    )
  }
  
  
  // MARK: Refresh
  
  func refreshFeed(userId: String? = nil) async throws {
    self.exploreCursor = .init()
    self.feedCursor = .init()
    try await self.loadPublicationsForFeed(userId: userId)
  }
  
  func loadAdditionalPublicationsForFeed(userId: String) async throws {
    guard !self.exploreCursor.exhausted, !self.feedCursor.exhausted
    else { return }
    try await self.loadPublicationsForFeed(userId: userId, feedCursor: self.feedCursor, exploreCursor: self.exploreCursor)
  }
  
  func loadAdditionalPublicationsForFeed() async throws {
    guard !self.exploreCursor.exhausted
    else { return }
    try await self.loadPublicationsForFeed(exploreCursor: self.exploreCursor)
  }
  
  func refreshNotifications(userId: String) async throws {
    self.notificationsCursor = .init()
    try await self.loadNotifications(userId: userId)
  }
  
  func loadAdditionalNotifications(userId: String) async throws {
    guard !self.notificationsCursor.exhausted
    else { return }
    try await self.loadNotifications(userId: userId, cursor: self.notificationsCursor)
  }
  
  
  // MARK: Update
  
  func updatePublication(_ publication: Model.Publication, _ updateType: UpdateType) throws {
    let realm = try Realm(configuration: Self.realmConfig)
    try realm.write { realm.add(publication.realmPublication(), update: .modified) }
    Task {
      switch updateType {
        case .addReaction(userProfileId: let userProfileId):
          try await self.lensApi.addReaction(userProfileId, .upvote, publication.id)
        case .removeReaction(userProfileId: let userProfileId):
          try await self.lensApi.removeReaction(userProfileId, .upvote, publication.id)
      }
    }
  }
  
  
  // MARK: Helper
  
  @MainActor
  private func loadPublicationsForFeed(userId: String? = nil, feedCursor: Cursor? = nil, exploreCursor: Cursor? = nil) async throws {
    let publications: [Model.Publication]
    if let userId {
      let feed = try await lensApi.feed(40, feedCursor?.next, userId, userId)
      let exploration = try await lensApi.explorePublications(10, exploreCursor?.next, .topCommented, [.post, .comment, .mirror], userId)
      
      self.exploreCursor = exploration.cursor
      self.feedCursor = feed.cursor
      publications = feed.data + exploration.data
    }
    else {
      let exploration = try await lensApi.explorePublications(50, exploreCursor?.next, .topCommented, [.post, .comment, .mirror], nil)
      self.exploreCursor = exploration.cursor
      publications = exploration.data
    }
    
    // Update feed
    let realmPublications = publications.compactMap { $0.realmPublication() }
    let realm = try! await Realm(configuration: Self.realmConfig)
    try realm.write {
      realmPublications.forEach {
        realm.add($0, update: .modified)
      }
    }
  }
  
  @MainActor
  private func loadNotifications(userId: String, cursor: Cursor? = nil) async throws {
    let notifications = try await lensApi.notifications(userId, 50, cursor?.next)
    let realmNotifications = notifications.data.compactMap { $0.realmNotification() }
    self.notificationsCursor = notifications.cursor
    
    let realm = try! await Realm(configuration: Self.realmConfig)
    try realm.write {
      realmNotifications.forEach {
        realm.add($0, update: .modified)
      }
    }
  }
  
  @MainActor
  private func fetchElement<CacheModel: Object, ViewModel: Presentable>(
    primaryKey: String,
    transformToViewModel: (CacheModel) -> ViewModel?,
    transformToCacheModel: @escaping (ViewModel) -> CacheModel?,
    fetch: @escaping () async throws -> ViewModel?
  ) async throws -> ViewModel? {
    
    let realm = try await Realm(configuration: Self.realmConfig)
    if let realmResult = realm.object(ofType: CacheModel.self, forPrimaryKey: primaryKey) {
      // Element available in cache, proceed and fetch async
      Task {
        let realm = try await Realm(configuration: Self.realmConfig)
        if let apiResult = try await fetch(), let cacheModel = transformToCacheModel(apiResult) {
          try realm.write { realm.add(cacheModel, update: .modified) }
        }
      }
      return transformToViewModel(realmResult)
    }
    else {
      // Element not available in cache, wait until fetched from API
      if let apiResult = try await fetch(), let cacheModel = transformToCacheModel(apiResult) {
        try realm.write { realm.add(cacheModel) }
        return apiResult
      }
      else {
        return nil
      }
    }
  }
  
  @MainActor
  private func fetchElement<CacheModel: Object, ViewModel: Presentable>(
    where: (Query<CacheModel>) -> Query<Bool>,
    transformToViewModel: (CacheModel) -> ViewModel?,
    transformToCacheModel: @escaping (ViewModel) -> CacheModel?,
    fetch: @escaping () async throws -> ViewModel?
  ) async throws -> ViewModel? {
    
    let realm = try await Realm(configuration: Self.realmConfig)
    let realmResult = realm.objects(CacheModel.self)
      .where(`where`)
    
    if realmResult.elements.count == 0 {
      // Element not available in cache, wait until fetched from API
      if let apiResult = try await fetch(), let cacheModel = transformToCacheModel(apiResult) {
        try realm.write { realm.add(cacheModel) }
        return apiResult
      }
      else {
        return nil
      }
    }
    else {
      // Element available in cache, proceed and fetch async
      Task {
        let realm = try await Realm(configuration: Self.realmConfig)
        if let apiResult = try await fetch(), let cacheModel = transformToCacheModel(apiResult) {
          try realm.write { realm.add(cacheModel, update: .modified) }
        }
      }
      if let cacheModel = realmResult.elements.first {
        return transformToViewModel(cacheModel)
      }
      else {
        return nil
      }
    }
  }
  
  @MainActor
  private func fetchElements<CacheModel: Object, ViewModel: Presentable>(
    where: (Query<CacheModel>) -> Query<Bool>,
    transformToViewModel: (CacheModel) -> ViewModel?,
    transformToCacheModel: @escaping (ViewModel) -> CacheModel?,
    fetch: @escaping () async throws -> [ViewModel]
  ) async throws -> [ViewModel] {
    
    let realm = try await Realm(configuration: Self.realmConfig)
    let realmResult = realm
      .objects(CacheModel.self)
      .where(`where`)
    
    if realmResult.elements.count == 0 {
      // Elements not available in cache, wait until fetched from API
      let viewModels = try await fetch()
      let cacheModels = viewModels.compactMap(transformToCacheModel)
      try cacheModels.forEach { cacheModel in
        try realm.write { realm.add(cacheModel, update: .modified) }
      }
      return viewModels
    }
    else {
      // Elements available in cache, proceed and fetch async
      Task {
        let viewModels = try await fetch()
        let cacheModels = viewModels.compactMap(transformToCacheModel)
        try cacheModels.forEach { cacheModel in
          try realm.write { realm.add(cacheModel, update: .modified) }
        }
      }
      return realmResult.compactMap(transformToViewModel)
    }
  }
}
