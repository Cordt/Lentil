// Lentil

import Asynchrone
import Dependencies
import Foundation
import IdentifiedCollections
import RealmSwift


class Cache {
  static var shared = Cache()
  
  private static let realmIdentifier: String = "LentilMemoryRealm"
  
  private var eventStream: CacheEvents
  private(set) var sharedEventStream: SharedAsyncSequence<CacheEvents>
  private var feedNotificationToken: NotificationToken?
  
  private var exploreCursor: Cursor
  private var feedCursor: Cursor
  
  @Dependency(\.lensApi) var lensApi
  
  private init() {
    self.eventStream = CacheEvents()
    self.sharedEventStream = self.eventStream.shared()
    self.feedNotificationToken = nil
    self.exploreCursor = .init()
    self.feedCursor = .init()
    
    self.registerObservers()
  }
  
  
  // MARK: Read
  
  func publication(for id: String) -> Model.Publication? {
    self.realm()
      .object(ofType: RealmPublication.self, forPrimaryKey: id)?
      .publication()
  }
  
  func publicationsForFeed() throws -> [Model.Publication] {
    self.realm()
      .objects(RealmPublication.self)
      .where { $0.showsInFeed == true }
      .sorted { $0.createdAt > $1.createdAt }
      .compactMap { $0.publication() }
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
  
  
  // MARK: Helper
  
  private func realm() -> Realm {
    try! Realm(
      configuration: Realm.Configuration(
        inMemoryIdentifier: Self.realmIdentifier
      )
    )
  }
  
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
    
    try self.realm().write {
      realmPublications.forEach {
        self.realm().add($0, update: .modified)
      }
    }
  }
  
  private func registerObservers() {
    Task { @MainActor in
    let feed = self.realm()
      .objects(RealmPublication.self)
      .where { $0.showsInFeed == true }
    
      self.feedNotificationToken = feed.observe { [weak self] (changes: RealmCollectionChange) in
        switch changes {
          case .initial(let publications):
            self?.eventStream.append(
              event: .initial(
                publications.elements.compactMap { $0.publication() }
              )
            )
          case .update(let publications, deletions: let deletions, insertions: let insertions, modifications: let modifications):
            self?.eventStream.append(
              event: .update(
                publications.elements.compactMap { $0.publication() },
                deletions: deletions,
                insertions: insertions,
                modifications: modifications
              )
            )
          case .error(let error):
            log("Failed to retrieve notification for updated feed", level: .error, error: error)
        }
      }
    }
  }
}


class CacheEvents: AsyncSequence, AsyncIteratorProtocol {
  enum Event {
    case initial([Model.Publication])
    case update([Model.Publication], deletions: [Int], insertions: [Int], modifications: [Int])
  }
  
  typealias Element = Event
  private var eventsToEmit: [Event] = []
  
  func append(event: Event) {
    self.eventsToEmit.append(event)
  }
  
  func next() async throws -> Element? {
    while true {
      try await Task.sleep(nanoseconds: NSEC_PER_SEC / 4)
      if !self.eventsToEmit.isEmpty {
        return self.eventsToEmit.removeFirst()
      }
    }
  }
  
  func makeAsyncIterator() -> CacheEvents {
    self
  }
}
