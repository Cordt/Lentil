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
  
  @Dependency(\.lensApi) var lensApi
  
  private init() {
    self.realmReference = try! Realm(configuration: Self.realmConfig)
    self.exploreCursor = .init()
    self.feedCursor = .init()
  }
  
  
  // MARK: Read
  
  func getObserver<Element: ViewModel>(observable: Observer<Element>.ObservableEvents) -> Observer<Element> {
    Observer(observable: observable)
  }
  
  func publication(for id: String) -> Model.Publication? {
    let realm = try! Realm(configuration: Self.realmConfig)
    return realm
      .object(ofType: RealmPublication.self, forPrimaryKey: id)?
      .publication()
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
}


class Observer<Element: ViewModel>: Equatable {
  
  enum ObservableEvents {
    case feed, notifications
  }
  
  static func == (lhs: Observer<Element>, rhs: Observer<Element>) -> Bool {
    lhs === rhs
  }
  
  let events: CacheEvents<Element>
  let observableEvents: ObservableEvents
  private var notificationToken: NotificationToken? = nil
  
  init(observable: ObservableEvents) {
    self.events = CacheEvents<Element>()
    self.observableEvents = observable
    
    Task { @MainActor in
      let realm = try! Realm(
        configuration: Realm.Configuration(
          inMemoryIdentifier: LentilEnvironment.shared.memoryRealmIdentifier
        )
      )
      
      switch self.observableEvents {
        case .feed:
          let results = realm
            .objects(RealmPublication.self)
            .where { $0.showsInFeed == true }
          
          self.notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
              case .initial(let publications):
                self?.events.append(
                  event: .initial(
                    publications.elements.compactMap { $0.publication() as? Element }
                  )
                )
              case .update(let publications, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                self?.events.append(
                  event: .update(
                    publications.elements.compactMap { $0.publication() as? Element },
                    deletions: deletions,
                    insertions: insertions,
                    modifications: modifications
                  )
                )
              case .error(let error):
                log("Failed to retrieve notification for updated feed", level: .error, error: error)
            }
          }
        case .notifications:
          let results = realm
            .objects(RealmNotification.self)
          
          self.notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
              case .initial(let publications):
                self?.events.append(
                  event: .initial(
                    publications.elements.compactMap { $0.notification() as? Element }
                  )
                )
              case .update(let publications, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                self?.events.append(
                  event: .update(
                    publications.elements.compactMap { $0.notification() as? Element },
                    deletions: deletions,
                    insertions: insertions,
                    modifications: modifications
                  )
                )
              case .error(let error):
                log("Failed to retrieve notification for updated notifications", level: .error, error: error)
            }
          }
      }
    }
  }
}

class CacheEvents<Model: ViewModel>: AsyncSequence, AsyncIteratorProtocol {
  enum Event<Model> {
    case initial([Model])
    case update([Model], deletions: [Int], insertions: [Int], modifications: [Int])
  }
  
  typealias Element = Event<Model>
  private var eventsToEmit: [Element] = []
  
  func append(event: Element) {
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
