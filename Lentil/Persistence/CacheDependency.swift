// Lentil

import Asynchrone
import Dependencies
import XCTestDynamicOverlay


struct CacheApi {
  var feedObserver: () -> CollectionObserver<Model.Publication>
  var notificationsObserver: () -> CollectionObserver<Model.Notification>
  var publicationObserver: (_ publicationId: String) -> ElementObserver<Model.Publication>
  var profileObserver: (_ profileId: String) -> ElementObserver<Model.Profile>
  var profile: (_ id: String) async throws -> Model.Profile?
  var publication: (_ id: String) async throws -> Model.Publication?
  var comments: (_ publication: Model.Publication, _ userId: String?) async throws -> [Model.Publication]
  var refreshFeed: (_ userId: String?) async throws -> Void
  var loadAdditionalPublicationsForFeedAuthenticated: (_ userId: String) async throws -> Void
  var loadAdditionalPublicationsForFeed: () async throws -> Void
  var refreshNotifications: (_ userId: String) async throws -> Void
  var loadAdditionalNotifications: (_ userId: String) async throws -> Void
}


extension CacheApi: DependencyKey {
  static let liveValue = CacheApi(
    feedObserver: { CollectionObserver(observable: .feed) },
    notificationsObserver: { CollectionObserver(observable: .notifications) },
    publicationObserver: { ElementObserver(observable: .publication($0)) },
    profileObserver: { ElementObserver(observable: .profile($0)) },
    profile: Cache.shared.profile,
    publication: Cache.shared.publication,
    comments: Cache.shared.comments,
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
    publicationObserver: unimplemented("publicationObserver"),
    profileObserver: unimplemented("profileObserver"),
    profile: unimplemented("profile"),
    publication: unimplemented("publication"),
    comments: unimplemented("comments"),
    refreshFeed: unimplemented("refreshFeed"),
    loadAdditionalPublicationsForFeedAuthenticated: unimplemented("loadAdditionalPublicationsForFeedAuthenticated"),
    loadAdditionalPublicationsForFeed: unimplemented("loadAdditionalPublicationsForFeed"),
    refreshNotifications: unimplemented("refreshNotifications"),
    loadAdditionalNotifications: unimplemented("loadAdditionalNotifications")
  )
}
#endif
