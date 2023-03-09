// Lentil
// Created by Laura and Cordt Zermin

import IdentifiedCollections
import Dependencies
import Foundation
import SwiftUI
import XCTestDynamicOverlay


struct NavigationApi {
  var eventStream: () -> NavigationEvents
  var pathBinding: () -> Binding<IdentifiedArrayOf<DestinationPath>>
  var append: (DestinationPath) -> ()
  var remove: (DestinationPath) -> ()
}

struct DestinationPath: Identifiable, Equatable, Hashable {
  // Creates strong coupling between this Dependency and all features that use it - needs improvement
  enum  Destination: Equatable, Hashable {
    case publication(_ elementId: String)
    case profile(_ elementId: String)
    case showNotifications
    case createPublication(_ reason: CreatePublication.State.Reason)
    case imageDetail(_ imageUrl: URL)
    
    case conversation(_ conversation: XMTPConversation, _ userAddress: String)
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(self)
    }
  }
  var id: String { self.navigationId }
  var navigationId: String
  var destination: Destination
}

class Navigation {
  static let shared = Navigation()
  var eventStream: NavigationEvents
  var path: IdentifiedArrayOf<DestinationPath> = []
  
  private init() {
    self.eventStream = NavigationEvents()
  }
  
  func events() -> NavigationEvents {
    self.eventStream
  }
  
  func pathBinding() -> Binding<IdentifiedArrayOf<DestinationPath>> {
    Binding(
      get: { self.path },
      set: { self.path = $0 }
    )
  }
  
  func append(item: DestinationPath) {
    self.eventStream.eventsToEmit.append(.append(item))
    self.path.append(item)
  }
  
  func remove(item: DestinationPath) {
    self.path.remove(id: item.navigationId)
    self.eventStream.eventsToEmit.append(.remove(item))
  }
}

class NavigationEvents: AsyncSequence, AsyncIteratorProtocol {
  enum Event {
    case append(DestinationPath)
    case remove(DestinationPath)
  }
  
  typealias Element = Event
  var eventsToEmit: [Event] = []
  
  func next() async throws -> Element? {
    while true {
      try await Task.sleep(nanoseconds: NSEC_PER_SEC / 50)
      if !self.eventsToEmit.isEmpty {
        return self.eventsToEmit.removeFirst()
      }
    }
  }
  
  func makeAsyncIterator() -> NavigationEvents {
    self
  }
}


extension DependencyValues {
  var navigationApi: NavigationApi {
    get { self[NavigationApi.self] }
    set { self[NavigationApi.self] = newValue }
  }
}

extension NavigationApi: DependencyKey {
  static var liveValue: NavigationApi {
    NavigationApi(
      eventStream: Navigation.shared.events,
      pathBinding: Navigation.shared.pathBinding,
      append: Navigation.shared.append,
      remove: Navigation.shared.remove
    )
  }
}

#if DEBUG
extension NavigationApi {
  static var testValue = NavigationApi(
    eventStream: unimplemented("eventStream"),
    pathBinding: unimplemented("pathBinding"),
    append: unimplemented("append"),
    remove: unimplemented("remove")
  )
}
#endif
