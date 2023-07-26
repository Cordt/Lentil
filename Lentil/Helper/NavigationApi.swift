// Lentil
// Created by Laura and Cordt Zermin

import IdentifiedCollections
import Dependencies
import Foundation
import SwiftUI
import XCTestDynamicOverlay

// TODO: Create a generic protocol for Root.Action.Destination
struct Navigate {
  var eventStream: () -> NavigationEvents
  var navigate: (_ to: Root.Action.Destination) -> ()
}


class Navigation {
  static let shared = Navigation()
  var eventStream: NavigationEvents
  
  private init() {
    self.eventStream = NavigationEvents()
  }
  
  func events() -> NavigationEvents {
    self.eventStream
  }
  
  func navigate(to: Root.Action.Destination) {
    self.eventStream.eventsToEmit.append(.navigate(to))
  }
}

class NavigationEvents: AsyncSequence, AsyncIteratorProtocol {
  enum Event {
    case navigate(_ to: Root.Action.Destination)
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
  var navigate: Navigate {
    get { self[Navigate.self] }
    set { self[Navigate.self] = newValue }
  }
}

extension Navigate: DependencyKey {
  static var liveValue: Navigate {
    Navigate(
      eventStream: Navigation.shared.events,
      navigate: Navigation.shared.navigate(to:)
    )
  }
}

#if DEBUG
extension Navigate {
  static var testValue = Navigate(
    eventStream: unimplemented("eventStream"),
    navigate: unimplemented("navigate")
  )
}
#endif
