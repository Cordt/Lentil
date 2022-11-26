// Lentil
// Created by Laura and Cordt Zermin

import IdentifiedCollections
import Dependencies
import Foundation
import SwiftUI


// FIXME: TMP
var publicationsCache: IdentifiedArrayOf<Model.Publication> = []
var profilesCache: IdentifiedArrayOf<Model.Profile> = []

extension NavigationApi: DependencyKey {
  static var liveValue: NavigationApi {
    NavigationApi(
      eventStream: Navigation.shared.eventStream,
      pathBinding: Navigation.shared.pathBinding,
      append: Navigation.shared.append,
      remove: Navigation.shared.remove
    )
  }
}

extension DependencyValues {
  var navigationApi: NavigationApi {
    get { self[NavigationApi.self] }
    set { self[NavigationApi.self] = newValue }
  }
}

struct NavigationApi {
  var eventStream: NavigationEvents
  var pathBinding: () -> Binding<IdentifiedArrayOf<DestinationPath>>
  var append: (DestinationPath) -> ()
  var remove: (DestinationPath) -> ()
}

struct DestinationPath: Identifiable, Equatable, Hashable {
  var navigationId: String
  var elementId: String
  var id: String { self.navigationId }
}

fileprivate class Navigation {
  static let shared = Navigation()
  var eventStream: NavigationEvents
  var path: IdentifiedArrayOf<DestinationPath> = []
  
  private init() {
    self.eventStream = NavigationEvents()
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
      try await Task.sleep(nanoseconds: NSEC_PER_SEC / 10)
      if !self.eventsToEmit.isEmpty {
        return self.eventsToEmit.removeFirst()
      }
    }
  }
  
  func makeAsyncIterator() -> NavigationEvents {
    self
  }
}

