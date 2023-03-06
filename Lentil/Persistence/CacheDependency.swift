// Lentil

import Asynchrone
import Dependencies
import XCTestDynamicOverlay


struct CacheApi {
  var feedObserver: () -> Observer<Model.Publication>
  var publication: (_ id: String) -> Model.Publication?
  var refreshFeed: (_ userId: String?) async throws -> Void
  var loadAdditionalPublicationsForFeedAuthenticated: (_ userId: String) async throws -> Void
  var loadAdditionalPublicationsForFeed: () async throws -> Void
}


extension CacheApi: DependencyKey {
  static let liveValue = CacheApi(
    feedObserver: { Cache.shared.getObserver(observable: .feed) },
    publication: Cache.shared.publication,
    refreshFeed: Cache.shared.refreshFeed,
    loadAdditionalPublicationsForFeedAuthenticated: Cache.shared.loadAdditionalPublicationsForFeed(userId:),
    loadAdditionalPublicationsForFeed: Cache.shared.loadAdditionalPublicationsForFeed
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
    publication: unimplemented("publication"),
    refreshFeed: unimplemented("refreshFeed"),
    loadAdditionalPublicationsForFeedAuthenticated: unimplemented("loadAdditionalPublicationsForFeedAuthenticated"),
    loadAdditionalPublicationsForFeed: unimplemented("loadAdditionalPublicationsForFeed")
  )
}
#endif
