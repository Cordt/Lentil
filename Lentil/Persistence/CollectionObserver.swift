// Lentil

import Foundation
import RealmSwift


class CollectionObserver<Element: Presentable>: Equatable {
  enum ObservableEvents {
    case feed, comments(_ parentPublicationId: String), notifications
  }
  
  static func == (lhs: CollectionObserver<Element>, rhs: CollectionObserver<Element>) -> Bool {
    lhs === rhs
  }
  
  let events: ObservableCollectionEventIterator<Element>
  let observableEvents: ObservableEvents
  private var notificationToken: NotificationToken? = nil
  

  init(observable: ObservableEvents) {
    self.events = ObservableCollectionEventIterator<Element>()
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
          
          self.notificationToken = self.buildCollectionObserver(results) { $0.publication() as? Element }
          
        case .comments(let parentPublicationId):
          let results = realm
            .objects(RealmPublication.self)
            .where { $0.parentPublication.id == parentPublicationId }
          
          self.notificationToken = self.buildCollectionObserver(results) { $0.publication() as? Element }
          
        case .notifications:
          let results = realm
            .objects(RealmNotification.self)
          
          self.notificationToken = self.buildCollectionObserver(results) { $0.notification() as? Element }
         
      }
    }
  }
  
  private func buildCollectionObserver<Observable: Object>(
    _ observableResults: Results<Observable>,
    _ transform: @escaping (Observable) -> Element?
  ) -> NotificationToken {
    return observableResults.observe { [weak self] (changes: RealmCollectionChange) in
      switch changes {
        case .initial(let collection):
          self?.events.append(
            event: .initial(
              collection.elements.compactMap(transform)
            )
          )
        case .update(let collection, deletions: _, insertions: let insertions, modifications: let modifications):
          var elementsToUpdate: [Observable] = []
          insertions.forEach { elementsToUpdate.append(collection.elements[$0]) }
          modifications.forEach { elementsToUpdate.append(collection.elements[$0]) }
          self?.events.append(
            event: .update(elementsToUpdate.compactMap(transform))
          )
        case .error(let error):
          log("Failed to build observer for collection of type \(Element.self)", level: .error, error: error)
      }
    }
  }
}


class ObservableCollectionEventIterator<Model: Presentable>: AsyncSequence, AsyncIteratorProtocol {
  enum Event<Model> {
    case initial([Model])
    case update([Model])
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
  
  func makeAsyncIterator() -> ObservableCollectionEventIterator {
    self
  }
}
