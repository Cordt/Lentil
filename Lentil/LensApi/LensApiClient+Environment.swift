// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import SwiftUI
import UIKit


extension LensApi: DependencyKey {
  static let liveValue = LensApi(
    authenticationChallenge: { address in
      try await run(
        query: ChallengeQuery(request: .init(address: address)),
        mapResult: { data in
          QueryResult(
            data:
              Challenge(
                message: data.challenge.text,
                expires: Date().addingTimeInterval(60 * 5)
              )
          )
        }
      )
    },
    
    verify: { accessToken in
      try await run(
        query: VerifyQuery(request: VerifyRequest(accessToken: accessToken)),
        mapResult: { data in
          QueryResult(
            data: data.verify
          )
        }
      )
    },
    
    publication: { txHash in
      try await run(
        query: PublicationQuery(
          request: PublicationQueryRequest(
            txHash: txHash
          )
        ),
        cachePolicy: .fetchIgnoringCacheData,
        mapResult: { data in
          QueryResult(
            data: Model.Publication.publication(from: data.publication)
          )
        }
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
        mapResult: { data in
          QueryResult(
            data: data.publications.items.compactMap { Model.Publication.publication(from: $0) },
            cursorToNext: data.publications.pageInfo.next
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
        mapResult: { data in
          QueryResult(
            data: data.explorePublications.items.compactMap { Model.Publication.publication(from: $0) },
            cursorToNext: data.explorePublications.pageInfo.next
          )
        }
      )
    },
    
    feed: { limit, cursor, profileId, reactionsForProfile in
      var reactionFieldRequest: ReactionFieldResolverRequest?
      if let profileId = reactionsForProfile { reactionFieldRequest = ReactionFieldResolverRequest(profileId: profileId) }
      return try await run(
        query: FeedQuery(
          request: FeedRequest(
            limit: "\(limit)",
            cursor: cursor,
            profileId: profileId
          ),
          reactionRequest: reactionFieldRequest
        ),
        mapResult: { data in
          QueryResult(data: data.feed.items.compactMap { Model.Publication.publication(from: $0.root) })
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
          QueryResult(
            data: data.publications.items.compactMap {
              Model.Publication.publication(from: $0, child: publication)
            }
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
          return QueryResult(data: Model.Profile.from(profileFields))
        }
      )
    },
    
    profile: { forHandle in
      try await run(
        query: ProfileQuery(request: SingleProfileQueryRequest(handle: forHandle)),
        mapResult: { data in
          guard let profileFields = data.profile?.fragments.profileFields else { return QueryResult(data: nil) }
          return QueryResult(data: Model.Profile.from(profileFields))
        }
      )
    },
    
    profiles: { ownedBy in
      try await run(
        query: ProfilesQuery(request: ProfileQueryRequest(ownedBy: [ownedBy])),
        mapResult: { data in
          QueryResult(data: Model.Profile.from(data.profiles))
        }
      )
    },
    
    fetchImage: { url in
      let (data, _) = try await URLSession.shared.data(from: url)
      guard let uiImage = UIImage(data: data)
      else { throw ApiError.requestFailed }
      return Image(uiImage: uiImage)
    },
    
    broadcast: { id, signature in
      try await run(
        networkClient: .authenticated,
        mutation: BroadcastMutation(
          request: BroadcastRequest(
            id: id,
            signature: signature
          )
        ),
        mapResult: { data in
          if let result = data.broadcast.asRelayerResult {
            return MutationResult(data: .success(RelayerResult(txnHash: result.txHash, txnId: result.txId)))
          }
          else if let error = data.broadcast.asRelayError {
            return MutationResult(data: .failure(error.reason))
          }
          else {
            return MutationResult(data: .failure(.__unknown("[ERROR] Received unexpected failure from Broadcast")))
          }
        }
      )
    },
    
    authenticate: { address, signature in
      try await run(
        mutation: AuthenticateMutation(request: SignedAuthChallenge(address: address, signature: signature)),
        mapResult: { data in
          MutationResult(
            data: AuthenticationTokens(
              accessToken: data.authenticate.accessToken,
              refreshToken: data.authenticate.refreshToken
            )
          )
        }
      )
    },
    
    refreshAuthentication: { refreshToken in
      try await run(
        mutation: RefreshMutation(request: RefreshRequest(refreshToken: refreshToken)),
        mapResult: { data in
          MutationResult(
            data: AuthenticationTokens(
              accessToken: data.refresh.accessToken,
              refreshToken: data.refresh.refreshToken
            )
          )
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
            return MutationResult(data: .success(RelayerResult(txnHash: result.txHash, txnId: result.txId)))
          }
          else if let error = data.createPostViaDispatcher.asRelayError {
            return MutationResult(data: .failure(error.reason))
          }
          else {
            return MutationResult(data: .failure(.__unknown("[ERROR] Received unexpected failure from CreatePostViaDispatcher")))
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
          return MutationResult(
            data: TypedDataResult(
              id: typedDataId,
              expires: expiresAt,
              typedData: typedData
            )
          )
        }
      )
    }
  )
  
#if DEBUG
  static let previewValue = LensApi(
    authenticationChallenge: { _ in QueryResult(data: Challenge(message: "Sign this message!", expires: Date().addingTimeInterval(60 * 5))) },
    verify: { _ in QueryResult(data: true) },
    publication: { _ in QueryResult(data: MockData.mockPublications[0]) },
    publications: { _, _, _, _, _ in QueryResult(data: MockData.mockPublications) },
    explorePublications: { _, _, _, _, _ in QueryResult(data: MockData.mockPublications) },
    feed: { _, _, _, _ in QueryResult(data: MockData.mockPublications) },
    commentsOfPublication: { _, _ in QueryResult(data: MockData.mockComments) },
    defaultProfile: { _ in QueryResult(data: MockData.mockProfiles[2]) },
    profile: { _ in QueryResult(data: MockData.mockProfiles[0]) },
    profiles: { _ in QueryResult(data: MockData.mockProfiles) },
    fetchImage: { url in
      if url.absoluteString == "https://profile-picture" { return Image("cryptopunk1") }
      else if url.absoluteString == "https://cover-picture" { return Image("munich") }
      else if url.absoluteString == "https://cover-picture-2" { return Image("crete") }
      else if url.absoluteString == "https://feed-picture" { return Image("munich") }
      else { throw ApiError.requestFailed }
    },
    broadcast: { _, _ in MutationResult(data: .success(.init(txnHash: "abc", txnId: "def"))) },
    authenticate: { _, _ in MutationResult(data: AuthenticationTokens(accessToken: "abc", refreshToken: "def")) },
    refreshAuthentication: { _ in MutationResult(data: AuthenticationTokens(accessToken: "abc", refreshToken: "def")) },
    createPost: { _, _ in MutationResult(data: .success(RelayerResult(txnHash: "abc", txnId: "123"))) },
    addReaction: { _, _, _ in },
    removeReaction: { _, _, _ in },
    getDefaultProfileTypedData: { _ in MutationResult(data: TypedDataResult(id: "abc", expires: Date().addingTimeInterval(60 * 60), typedData: mockTypedData)) }
  )
#endif
}

extension DependencyValues {
  var lensApi: LensApi {
    get { self[LensApi.self] }
    set { self[LensApi.self] = newValue }
  }
}
