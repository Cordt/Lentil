// Lentil

import Foundation
import RealmSwift


class Observer<Element: ViewModel>: Equatable {
  enum ObservableEvents {
    case feed, notifications
  }
  
  static func == (lhs: Observer<Element>, rhs: Observer<Element>) -> Bool {
    lhs === rhs
  }
  
  let events: ObservableEventIterator<Element>
  let observableEvents: ObservableEvents
  private var notificationToken: NotificationToken? = nil
  
  private func buildObserver<Observable: Object>(
    _ observableResults: Results<Observable>,
    _ transform: @escaping (Observable) -> Element?
  ) -> NotificationToken {
    return observableResults.observe { [weak self] (changes: RealmCollectionChange) in
      switch changes {
        case .initial(let publications):
          self?.events.append(
            event: .initial(
              publications.elements.compactMap(transform)
            )
          )
        case .update(let publications, deletions: let deletions, insertions: let insertions, modifications: let modifications):
          self?.events.append(
            event: .update(
              publications.elements.compactMap(transform),
              deletions: deletions,
              insertions: insertions,
              modifications: modifications
            )
          )
        case .error(let error):
          log("Failed to build observer for element of type \(Element.self)", level: .error, error: error)
      }
    }
  }
  
  init(observable: ObservableEvents) {
    self.events = ObservableEventIterator<Element>()
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
          
          self.notificationToken = self.buildObserver(results) { $0.publication() as? Element }
          
        case .notifications:
          let results = realm
            .objects(RealmNotification.self)
          
          self.notificationToken = self.buildObserver(results) { $0.notification() as? Element }
      }
    }
  }
}


class ObservableEventIterator<Model: ViewModel>: AsyncSequence, AsyncIteratorProtocol {
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
  
  func makeAsyncIterator() -> ObservableEventIterator {
    self
  }
}
