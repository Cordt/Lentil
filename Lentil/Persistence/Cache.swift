// Lentil

import Asynchrone
import Dependencies
import Foundation
import IdentifiedCollections
import RealmSwift


class Cache {
  static let shared = Cache()
  static let realmConfig = Realm.Configuration(inMemoryIdentifier: LentilEnvironment.shared.memoryRealmIdentifier)
  
  private var realmReference: Realm
  private var exploreCursor: Cursor
  private var feedCursor: Cursor
  private var notificationsCursor: Cursor
  
  @Dependency(\.lensApi) var lensApi
  
  private init() {
    self.realmReference = try! Realm(configuration: Self.realmConfig)
    self.exploreCursor = .init()
    self.feedCursor = .init()
    self.notificationsCursor = .init()
  }
  
  
  // MARK: Read
  
  func profile(for id: String) async throws -> Model.Profile? {
    let realm = try! await Realm(configuration: Self.realmConfig)
    var result = realm
      .object(ofType: RealmProfile.self, forPrimaryKey: id)?
      .profile()
    
    if result == nil {
      let apiProfile = try await self.lensApi.profile(id)
      if let realmProfile = apiProfile?.realmProfile() {
        try realm.write { realm.add(realmProfile) }
      }
      result = apiProfile
    }
    
    return result
  }
  
  func publication(for id: String) async throws -> Model.Publication? {
    let realm = try! await Realm(configuration: Self.realmConfig)
    var result = realm
      .object(ofType: RealmPublication.self, forPrimaryKey: id)?
      .publication()
    
    if result == nil {
      let apiPublication = try await self.lensApi.publicationById(id)
      if let realmPublication = apiPublication?.realmPublication(showsInFeed: false) {
        try realm.write { realm.add(realmPublication) }
      }
      result = apiPublication
    }
    
    return result
  }
  
  func comments(of publication: Model.Publication, for userId: String? = nil) async throws {
    let realm = try! await Realm(configuration: Self.realmConfig)
    var result = realm
      .objects(RealmPublication.self)
      .where { $0.parentPublication.id == publication.id }
    
    
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
    let realmPublications = publications.compactMap { $0.realmPublication(showsInFeed: true) }
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
}
