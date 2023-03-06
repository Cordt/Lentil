// Lentil

import Asynchrone
import Dependencies
import XCTestDynamicOverlay


struct CacheApi {
  var feedObserver: () -> Observer<Model.Publication>
  var notificationsObserver: () -> Observer<Model.Notification>
  var profile: (_ id: String) async throws -> Model.Profile?
  var publication: (_ id: String) async throws -> Model.Publication?
  var refreshFeed: (_ userId: String?) async throws -> Void
  var loadAdditionalPublicationsForFeedAuthenticated: (_ userId: String) async throws -> Void
  var loadAdditionalPublicationsForFeed: () async throws -> Void
  var refreshNotifications: (_ userId: String) async throws -> Void
  var loadAdditionalNotifications: (_ userId: String) async throws -> Void
}


extension CacheApi: DependencyKey {
  static let liveValue = CacheApi(
    feedObserver: { Cache.shared.getObserver(observable: .feed) },
    notificationsObserver: { Cache.shared.getObserver(observable: .notifications) },
    profile: Cache.shared.profile,
    publication: Cache.shared.publication,
    refreshFeed: Cache.shared.refreshFeed,
    loadAdditionalPublicationsForFeedAuthenticated: Cache.shared.loadAdditionalPublicationsForFeed(userId:),
    loadAdditionalPublicationsForFeed: Cache.shared.loadAdditionalPublicationsForFeed,
    refreshNotifications: Cache.shared.refreshNotifications,
    loadAdditionalNotifications: Cache.shared.loadAdditionalNotifications
  )
}

extension DependencyValues {
  var cache: CacheApi  {
    get { self[CacheApi.self] }
    set { self[CacheApi.self] = newValue }
  }
}


#if DEBUG
extension CacheApi {
  static let testValue = CacheApi(
    feedObserver: unimplemented("feedObserver"),
    notificationsObserver: unimplemented("notificationsObserver"),
    profile: unimplemented("profile"),
    publication: unimplemented("publication"),
    refreshFeed: unimplemented("refreshFeed"),
    loadAdditionalPublicationsForFeedAuthenticated: unimplemented("loadAdditionalPublicationsForFeedAuthenticated"),
    loadAdditionalPublicationsForFeed: unimplemented("loadAdditionalPublicationsForFeed"),
    refreshNotifications: unimplemented("refreshNotifications"),
    loadAdditionalNotifications: unimplemented("loadAdditionalNotifications")
  )
}
#endif
