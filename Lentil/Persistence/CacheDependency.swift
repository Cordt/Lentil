// Lentil

import Dependencies
import XCTestDynamicOverlay


struct CacheApi {
  var feedObserver: () -> CollectionObserver<Model.Publication>
  var notificationsObserver: () -> CollectionObserver<Model.Notification>
  var commentsObserver: (_ parentId: String) -> CollectionObserver<Model.Publication>
  var publicationObserver: (_ publicationId: String) -> ElementObserver<Model.Publication>
  var profileObserver: (_ profileId: String) -> ElementObserver<Model.Profile>
  
  var profile: (_ id: String) async throws -> Model.Profile?
  var profileByAddress: (_ id: String) async throws -> Model.Profile?
  var publication: (_ id: String) async throws -> Model.Publication?
  var comments: (_ publication: Model.Publication, _ userId: String?) async throws -> [Model.Publication]
  
  var refreshFeed: (_ userId: String?) async throws -> Void
  var loadAdditionalPublicationsForFeedAuthenticated: (_ userId: String) async throws -> Void
  var loadAdditionalPublicationsForFeed: () async throws -> Void
  var refreshNotifications: (_ userId: String) async throws -> Void
  var loadAdditionalNotifications: (_ userId: String) async throws -> Void
  
  var createPublication: (_ publicationType: Cache.PublicationUploadRequest.PublicationType,
                          _ publicationText: String,
                          _ userProfileId: String,
                          _ userProfileAddress: String,
                          _ uploadMedia: [Cache.PublicationUploadRequest.UploadMedia]) async throws -> Void
  
  var updatePublication: (_ publication: Model.Publication, _ updateType: Cache.UpdateType) throws -> Void
}


extension CacheApi: DependencyKey {
  static let liveValue = CacheApi(
    feedObserver: { CollectionObserver(observable: .feed) },
    notificationsObserver: { CollectionObserver(observable: .notifications) },
    commentsObserver: { CollectionObserver(observable: .comments($0)) },
    publicationObserver: { ElementObserver(observable: .publication($0)) },
    profileObserver: { ElementObserver(observable: .profile($0)) },
    profile: Cache.shared.profile(by:),
    profileByAddress: Cache.shared.profileBy(address:),
    publication: Cache.shared.publication,
    comments: Cache.shared.comments,
    refreshFeed: Cache.shared.refreshFeed,
    loadAdditionalPublicationsForFeedAuthenticated: Cache.shared.loadAdditionalPublicationsForFeed(userId:),
    loadAdditionalPublicationsForFeed: Cache.shared.loadAdditionalPublicationsForFeed,
    refreshNotifications: Cache.shared.refreshNotifications,
    loadAdditionalNotifications: Cache.shared.loadAdditionalNotifications,
    createPublication: Cache.shared.createPublication,
    updatePublication: Cache.shared.updatePublication
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
    commentsObserver: unimplemented("commentsObserver"),
    publicationObserver: unimplemented("publicationObserver"),
    profileObserver: unimplemented("profileObserver"),
    profile: unimplemented("profile"),
    profileByAddress: unimplemented("profileByAddress"),
    publication: unimplemented("publication"),
    comments: unimplemented("comments"),
    refreshFeed: unimplemented("refreshFeed"),
    loadAdditionalPublicationsForFeedAuthenticated: unimplemented("loadAdditionalPublicationsForFeedAuthenticated"),
    loadAdditionalPublicationsForFeed: unimplemented("loadAdditionalPublicationsForFeed"),
    refreshNotifications: unimplemented("refreshNotifications"),
    loadAdditionalNotifications: unimplemented("loadAdditionalNotifications"),
    createPublication: unimplemented("createPublication"),
    updatePublication: unimplemented("updatePublication")
  )
}
#endif
