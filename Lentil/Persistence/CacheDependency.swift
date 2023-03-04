// Lentil

import Asynchrone
import Dependencies
import XCTestDynamicOverlay


struct CacheApi {
  var sharedEventStream: SharedAsyncSequence<CacheEvents>
  var publication: (_ id: String) -> Model.Publication?
  var publicationsForFeed: () throws -> [Model.Publication]
  var refreshFeed: (_ userId: String?) async throws -> Void
  var loadAdditionalPublicationsForFeedAuthenticated: (_ userId: String) async throws -> Void
  var loadAdditionalPublicationsForFeed: () async throws -> Void
}


extension CacheApi: DependencyKey {
  static let liveValue = CacheApi(
    sharedEventStream: Cache.shared.sharedEventStream,
    publication: Cache.shared.publication,
    publicationsForFeed: Cache.shared.publicationsForFeed,
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
    sharedEventStream: unimplemented("sharedEventStream"),
    publication: unimplemented("publication"),
    publicationsForFeed: unimplemented("publicationsForFeed"),
    refreshFeed: unimplemented("refreshFeed"),
    loadAdditionalPublicationsForFeedAuthenticated: unimplemented("loadAdditionalPublicationsForFeedAuthenticated"),
    loadAdditionalPublicationsForFeed: unimplemented("loadAdditionalPublicationsForFeed")
  )
}
#endif
