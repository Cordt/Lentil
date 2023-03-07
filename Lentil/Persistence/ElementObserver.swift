// Lentil

import Foundation
import RealmSwift


class ElementObserver<Element: Presentable>: Equatable {
  enum ObservableEvents {
    case publication(_ id: String)
    case profile(_ id: String)
  }
  
  static func == (lhs: ElementObserver<Element>, rhs: ElementObserver<Element>) -> Bool {
    lhs === rhs
  }
  
  let events: ObservableElementEventIterator<Element>?
  let observableEvents: ObservableEvents
  private var notificationToken: NotificationToken? = nil
  
  
  init(observable: ObservableEvents) {
    self.events = ObservableElementEventIterator()
    self.observableEvents = observable
    
    Task { @MainActor in
      let realm = try! Realm(
        configuration: Realm.Configuration(
          inMemoryIdentifier: LentilEnvironment.shared.memoryRealmIdentifier
        )
      )
      
      switch self.observableEvents {
        case .publication(let id):
          let results = realm
            .objects(RealmPublication.self)
            .where { $0.id == id }
          
          self.notificationToken = self.buildElementObserver(results) { $0.publication() as? Element }
          
        case .profile(let id):
          let results = realm
            .objects(RealmProfile.self)
            .where { $0.id == id }
          
          self.notificationToken = self.buildElementObserver(results) { $0.profile() as? Element }
      }
    }
  }
  
  private func buildElementObserver<Observable: Object>(
    _ observableResults: Results<Observable>,
    _ transform: @escaping (Observable) -> Element?
  ) -> NotificationToken {
    return observableResults.observe { [weak self] (changes: RealmCollectionChange) in
      switch changes {
        case .initial(let collection), .update(let collection, deletions: _, insertions: _, modifications: _):
          guard let element = collection.elements.first,
                let transformed = transform(element)
          else { return }
          self?.events?.append(event: .update(transformed))
       
        case .error(let error):
          log("Failed to build observer for element of type \(Element.self)", level: .error, error: error)
      }
    }
  }
}


class ObservableElementEventIterator<Model: Presentable>: AsyncSequence, AsyncIteratorProtocol {
  enum Event<Model> {
    case update(Model)
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
  
  func makeAsyncIterator() -> ObservableElementEventIterator {
    self
  }
}
