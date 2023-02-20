// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import Foundation


extension DependencyValues {
  var lensApi: LensApi {
    get { self[LensApi.self] }
    set { self[LensApi.self] = newValue }
  }
}

extension LensApi: DependencyKey {
  static let liveValue = LensApi(
    authenticationChallenge: { address in
      try await run(
        query: ChallengeQuery(request: .init(address: address)),
        mapResult: { data in
          Challenge(
            message: data.challenge.text,
            expires: Date().addingTimeInterval(60 * 5)
          )
        }
      )
    },
    
    verify: {
      let accessToken = try KeychainStorage.shared.get(storable: AccessToken.access)
      return try await run(
        query: VerifyQuery(request: VerifyRequest(accessToken: accessToken)),
        mapResult: { $0.verify }
      )
    },
    
    publicationById: { id in
      try await run(
        query: PublicationQuery(
          request: PublicationQueryRequest(publicationId: id)
        ),
        cachePolicy: .fetchIgnoringCacheData,
        mapResult: { Model.Publication.publication(from: $0.publication) }
      )
    },
    
    publicationByHash: { txHash in
      try await run(
        query: PublicationQuery(
          request: PublicationQueryRequest(txHash: txHash)
        ),
        cachePolicy: .fetchIgnoringCacheData,
        mapResult: { Model.Publication.publication(from: $0.publication) }
      )
    },
    
    publications: { limit, cursor, profileId, publicationTypes, reactionsForProfile in
      var reactionFieldRequest: ReactionFieldResolverRequest?
      if let profileId = reactionsForProfile { reactionFieldRequest = ReactionFieldResolverRequest(profileId: profileId) }
      return try await run(
        query: PublicationsQuery(
          request: PublicationsQueryRequest(
            limit: "\(limit)",
            cursor: cursor,
            profileId: profileId,
            publicationTypes: publicationTypes
          ),
          reactionRequest: reactionFieldRequest
        ),
        cachePolicy: .fetchIgnoringCacheData,
        mapResult: { data in
          PaginatedResult(
            data: data.publications.items.compactMap { Model.Publication.publication(from: $0) },
            cursor: .init(prev: data.publications.pageInfo.prev, next: data.publications.pageInfo.next)
          )
        }
      )
    },
    
    explorePublications: { limit, cursor, sortCriteria, publicationTypes, reactionsForProfile in
      var reactionFieldRequest: ReactionFieldResolverRequest?
      if let profileId = reactionsForProfile { reactionFieldRequest = ReactionFieldResolverRequest(profileId: profileId) }
      return try await run(
        query: ExplorePublicationsQuery(
          request: ExplorePublicationRequest(
            limit: "\(limit)",
            cursor: cursor,
            sortCriteria: sortCriteria,
            publicationTypes: publicationTypes
          ),
          reactionRequest: reactionFieldRequest
        ),
        cachePolicy: .default,
        mapResult: { data in
          PaginatedResult(
            data: data.explorePublications.items.compactMap { Model.Publication.publication(from: $0) },
            cursor: .init(prev: data.explorePublications.pageInfo.prev, next: data.explorePublications.pageInfo.next)
          )
        }
      )
    },
    
    feed: { limit, cursor, profileId, reactionsForProfile in
      var reactionFieldRequest: ReactionFieldResolverRequest?
      if let profileId = reactionsForProfile { reactionFieldRequest = ReactionFieldResolverRequest(profileId: profileId) }
      return try await run(
        networkClient: .authenticated,
        query: FeedQuery(
          request: FeedRequest(
            limit: "\(limit)",
            cursor: cursor,
            profileId: profileId
          ),
          reactionRequest: reactionFieldRequest
        ),
        cachePolicy: .default,
        mapResult: { data in
          PaginatedResult(
            data: data.feed.items.compactMap { Model.Publication.publication(from: $0) },
            cursor: .init(prev: data.feed.pageInfo.prev, next: data.feed.pageInfo.next)
          )
        }
      )
    },
    
    commentsOfPublication: { publication, reactionsForProfile in
      var reactionFieldRequest: ReactionFieldResolverRequest?
      if let profileId = reactionsForProfile { reactionFieldRequest = ReactionFieldResolverRequest(profileId: profileId) }
      return try await run(
        query: PublicationsQuery(
          request: PublicationsQueryRequest(
            commentsOf: publication.id
          ),
          reactionRequest: reactionFieldRequest
        ),
        mapResult: { data in
          PaginatedResult(
            data: data.publications.items.compactMap {
              Model.Publication.publication(from: $0, child: publication)
            },
            cursor: .init(prev: data.publications.pageInfo.prev, next: data.publications.pageInfo.next)
          )
        }
      )
    },
    
    defaultProfile: { address in
      try await run(
        query: DefaultProfileQuery(
          request: DefaultProfileRequest(
            ethereumAddress: address
          )
        ),
        mapResult: { data in
          guard let profileFields = data.defaultProfile?.fragments.profileFields
          else { throw ApiError.requestFailed }
          return Model.Profile.from(profileFields)
        }
      )
    },
    
    profile: { forHandle in
      try await run(
        query: ProfileQuery(request: SingleProfileQueryRequest(handle: forHandle)),
        mapResult: { data in
          guard let profileFields = data.profile?.fragments.profileFields else { return nil }
          return Model.Profile.from(profileFields)
        }
      )
    },
    
    profiles: { ownedBy in
      try await run(
        query: ProfilesQuery(request: ProfileQueryRequest(ownedBy: [ownedBy])),
        mapResult: { data in
          PaginatedResult(
            data: Model.Profile.from(data.profiles),
            cursor: .init(prev: data.profiles.pageInfo.prev, next: data.profiles.pageInfo.next)
          )
        }
      )
    },
    
    fetchImage: { url in
      try await URLSession.shared.data(from: url).0
    },
    
    searchProfiles: { limit, query in
      try await run(
        networkClient: .unauthenticated,
        query: SearchQuery(
          request: SearchQueryRequest(
            limit: "\(limit)",
            query: query,
            type: .profile
          )
        ),
        cachePolicy: .returnCacheDataElseFetch,
        mapResult: { data in
          guard let profileSearchResult = data.search.asProfileSearchResult
          else { return PaginatedResult(data: [], cursor: .init()) }
          
          let profiles = profileSearchResult.items.compactMap {
            Model.Profile.from($0.fragments.profileFields)
          }
          return PaginatedResult(data: profiles, cursor: .init(prev: profileSearchResult.pageInfo.prev, next: profileSearchResult.pageInfo.next))
        }
      )
    },
    
    notifications: { profileID, limit, cursor in
      try await run(
        networkClient: .authenticated,
        query: NotificationsQuery(
          request: .init(limit: "\(limit)", cursor: cursor, profileId: profileID)
        ),
        mapResult: { data in
          let notifications = data.result.items.compactMap(Model.Notification.from)
          let pageInfo = data.result.pageInfo.fragments.commonPaginatedResultInfo
          return PaginatedResult(data: notifications, cursor: .init(prev: pageInfo.prev, next: pageInfo.next))
        }
      )
    },
    
    authenticate: { address, signature in
      try await run(
        mutation: AuthenticateMutation(request: SignedAuthChallenge(address: address, signature: signature)),
        mapResult: { data in
          try KeychainStorage.shared.store(string: data.authenticate.accessToken, for: AccessToken.access)
          try KeychainStorage.shared.store(string: data.authenticate.refreshToken, for: AccessToken.refresh)
        }
      )
    },
    
    refreshAuthentication: {
      let refreshToken = try KeychainStorage.shared.get(storable: AccessToken.refresh)
      try await run(
        mutation: RefreshMutation(request: RefreshRequest(refreshToken: refreshToken)),
        mapResult: { data in
          try KeychainStorage.shared.store(string: data.refresh.accessToken, for: AccessToken.access)
          try KeychainStorage.shared.store(string: data.refresh.refreshToken, for: AccessToken.refresh)
        }
      )
    },
    
    createPost: { profileId, contentUri in
      try await run(
        networkClient: .authenticated,
        mutation: CreatePostViaDispatcherMutation(
          request: CreatePublicPostRequest(
            profileId: profileId,
            contentUri: contentUri,
            collectModule: CollectModuleParams(freeCollectModule: FreeCollectModuleParams(followerOnly: false)),
            referenceModule: ReferenceModuleParams(followerOnlyReferenceModule: false)
          )
        ),
        mapResult: { data in
          if let result = data.createPostViaDispatcher.asRelayerResult {
            return .success(RelayerResult(txnHash: result.txHash, txnId: result.txId))
          }
          else if let error = data.createPostViaDispatcher.asRelayError {
            return .failure(error.reason)
          }
          else {
            return .failure(.__unknown("Received unexpected failure from CreatePostViaDispatcher"))
          }
        }
      )
    },
    
    createComment: { profileId, publicationId, contentUri in
      try await run(
        networkClient: .authenticated,
        mutation: CreateCommentViaDispatcherMutation(
          request: CreatePublicCommentRequest(
            profileId: profileId,
            publicationId: publicationId,
            contentUri: contentUri,
            collectModule: CollectModuleParams(freeCollectModule: FreeCollectModuleParams(followerOnly: false)),
            referenceModule: ReferenceModuleParams(followerOnlyReferenceModule: false)
          )
        ),
        mapResult: { data in
          if let result = data.createCommentViaDispatcher.asRelayerResult {
            return .success(RelayerResult(txnHash: result.txHash, txnId: result.txId))
          }
          else if let error = data.createCommentViaDispatcher.asRelayError {
            return .failure(error.reason)
          }
          else {
            return .failure(.__unknown("Received unexpected failure from CreatePostViaDispatcher"))
          }
        }
      )
    },
    
    addReaction: { profileId, reaction, publicationId in
      try await run(
        networkClient: .authenticated,
        mutation: AddReactionMutation(request: .init(profileId: profileId, reaction: reaction, publicationId: publicationId))
      )
    },
    
    removeReaction: { profileId, reaction, publicationId in
      try await run(
        networkClient: .authenticated,
        mutation: RemoveReactionMutation(request: .init(profileId: profileId, reaction: reaction, publicationId: publicationId))
      )
    },
    
    createMirror: { profileId, publicationId in
      try await run(
        networkClient: .authenticated,
        mutation: CreateMirrorViaDispatcherMutation(
          request: .init(
            profileId: profileId,
            publicationId: publicationId,
            referenceModule: ReferenceModuleParams(followerOnlyReferenceModule: false)
          )
        ),
        mapResult: { data in
          if let result = data.createMirrorViaDispatcher.asRelayerResult {
            return .success(RelayerResult(txnHash: result.txHash, txnId: result.txId))
          }
          else if let error = data.createMirrorViaDispatcher.asRelayError {
            return .failure(error.reason)
          }
          else {
            return .failure(.__unknown("Received unexpected failure from CreateMirrorViaDispatcher"))
          }
        }
      )
    },
    
    getDefaultProfileTypedData: { profileId in
      try await run(
        networkClient: .authenticated,
        mutation: CreateSetDefaultProfileTypedDataMutation(
          request: CreateSetDefaultProfileRequest(profileId: profileId)
        ),
        mapResult: { data in
          guard let expiresAt = date(from: data.createSetDefaultProfileTypedData.expiresAt)
          else { throw ApiError.cannotParseResponse }
          
          let typedDataId = data.createSetDefaultProfileTypedData.id
          let typedData = try typedData(
            from: data.createSetDefaultProfileTypedData.typedData.jsonObject,
            for: .setDefaultProfile
          )
          return TypedDataResult(
            id: typedDataId,
            expires: expiresAt,
            typedData: typedData
          )
        }
      )
    }
  )
}

#if DEBUG
import UIKit
import XCTestDynamicOverlay


extension LensApi {
  static let previewValue = LensApi(
    authenticationChallenge: { _ in Challenge(message: "Sign this message!", expires: Date().addingTimeInterval(60 * 5)) },
    verify: { true },
    publicationById: { _ in MockData.mockPublications[0] },
    publicationByHash: { _ in MockData.mockPublications[0] },
    publications: { _, _, _, _, _ in PaginatedResult(data: MockData.mockPublications, cursor: .init()) },
    explorePublications: { _, _, _, _, _ in PaginatedResult(data: MockData.mockPublications, cursor: .init()) },
    feed: { _, _, _, _ in PaginatedResult(data: MockData.mockPublications, cursor: .init()) },
    commentsOfPublication: { _, _ in PaginatedResult(data: MockData.mockComments, cursor: .init()) },
    defaultProfile: { _ in MockData.mockProfiles[2] },
    profile: { _ in MockData.mockProfiles[0] },
    profiles: { _ in PaginatedResult(data: MockData.mockProfiles, cursor: .init()) },
    fetchImage: { url in
      if url.absoluteString == "https://profile-picture" { return UIImage(named: "cryptopunk1")!.jpegData(compressionQuality: 0.5)! }
      else if url.absoluteString == "https://cover-picture" { return UIImage(named: "munich")!.jpegData(compressionQuality: 0.5)! }
      else if url.absoluteString == "https://crete" { return UIImage(named: "crete")!.jpegData(compressionQuality: 0.5)! }
      else if url.absoluteString == "https://feed-picture" { return UIImage(named: "munich")!.jpegData(compressionQuality: 0.5)! }
      else if url.absoluteString == "https://lentil-beta" { return UIImage(named: "lentilBeta")!.jpegData(compressionQuality: 0.5)! }
      else { throw ApiError.requestFailed }
    },
    searchProfiles: { _, query in
      try await Task.sleep(for: .seconds(2))
      if query.count == 3 { return PaginatedResult(data: [MockData.mockProfiles[0]], cursor: .init()) }
      else if query.count == 4 { return PaginatedResult(data: [MockData.mockProfiles[0], MockData.mockProfiles[1]], cursor: .init()) }
      else { return PaginatedResult(data: MockData.mockProfiles, cursor: .init()) }
    },
    notifications: { _, _, _ in PaginatedResult(data: MockData.mockNotifications, cursor: .init()) },
    authenticate: { _, _ in },
    refreshAuthentication: {},
    createPost: { _, _ in .success(RelayerResult(txnHash: "abc", txnId: "123")) },
    createComment: { _, _, _ in .success(RelayerResult(txnHash: "abc", txnId: "123")) },
    addReaction: { _, _, _ in },
    removeReaction: { _, _, _ in },
    createMirror: { _, _ in .success(RelayerResult(txnHash: "abc", txnId: "123")) },
    getDefaultProfileTypedData: { _ in TypedDataResult(id: "abc", expires: Date().addingTimeInterval(60 * 60), typedData: mockTypedData) }
  )
  
  static var testValue = LensApi(
    authenticationChallenge: unimplemented("authenticationChallenge"),
    verify: unimplemented("verify"),
    publicationById: unimplemented("publicationById"),
    publicationByHash: unimplemented("publicationByHash"),
    publications: unimplemented("publications"),
    explorePublications: unimplemented("explorePublications"),
    feed: unimplemented("feed"),
    commentsOfPublication: unimplemented("commentsOfPublication"),
    defaultProfile: unimplemented("defaultProfile"),
    profile: unimplemented("profile"),
    profiles: unimplemented("profiles"),
    fetchImage: unimplemented("fetchImage"),
    searchProfiles: unimplemented("searchProfiles"),
    notifications: unimplemented("notifications"),
    authenticate: unimplemented("authenticate"),
    refreshAuthentication: unimplemented("refreshAuthentication"),
    createPost: unimplemented("createPost"),
    createComment: unimplemented("createComment"),
    addReaction: unimplemented("addReaction"),
    removeReaction: unimplemented("removeReaction"),
    createMirror: unimplemented("createMirror"),
    getDefaultProfileTypedData: unimplemented("getDefaultProfileTypedData")
  )
}
#endif
