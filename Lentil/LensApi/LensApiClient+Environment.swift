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
    
    trendingPublications: { limit, cursor, sortCriteria, publicationTypes in
      try await run(
        query: ExplorePublicationsQuery(
          request: ExplorePublicationRequest(
            limit: "\(limit)",
            cursor: cursor,
            sortCriteria: sortCriteria,
            publicationTypes: publicationTypes
          )
        ),
        mapResult: { data in
          QueryResult(
            data: data.explorePublications.items.compactMap(Model.Publication.from),
            cursorToNext: data.explorePublications.pageInfo.next
          )
        }
      )
    },
    
    commentsOfPublication: { publication in
      try await run(
        query: PublicationsQuery(
          request: PublicationsQueryRequest(
            commentsOf: publication.id
          )
        ),
        mapResult: { data in
          QueryResult(
            data: data.publications.items.compactMap {
              Model.Publication.from($0, child: publication)
            }
          )
        }
      )
    },
    
    reactionsOfPublication: { publication in
      try await run(
        query: WhoReactedPublicationQuery(
          request: WhoReactedPublicationRequest(publicationId: publication.id)
        ),
        mapResult: { data in
          var updatedPublication = publication
          data.whoReactedPublication.items.forEach { item in
            if item.reaction == .upvote { updatedPublication.upvotes += 1 }
            if item.reaction == .downvote { updatedPublication.downvotes += 1 }
            
          }
          return QueryResult(
            data: updatedPublication
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
          if let defaultProfile = Model.Profile.from(data.defaultProfile) {
            return QueryResult(data: defaultProfile)
          }
          else { throw ApiError.requestFailed }
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
            return MutationResult(data: .success(Broadcast(txnHash: result.txHash, txnId: result.txId)))
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
    trendingPublications: { _, _, _, _ in return QueryResult(data: mockPublications) },
    commentsOfPublication: { _ in QueryResult(data: mockComments) },
    reactionsOfPublication: { publication in QueryResult(data: mockPosts.first(where: { $0.id == publication.id })!) },
    defaultProfile: { _ in QueryResult(data: mockProfiles[2]) },
    profiles: { _ in QueryResult(data: mockProfiles) },
    fetchImage: { url in
      if url.absoluteString == "https://profile-picture" { return Image("cryptopunk1") }
      else if url.absoluteString == "https://cover-picture" { return Image("munich") }
      else { throw ApiError.requestFailed }
    },
    broadcast: { _, _ in MutationResult(data: .success(.init(txnHash: "abc", txnId: "def"))) },
    authenticate: { _, _ in MutationResult(data: AuthenticationTokens(accessToken: "abc", refreshToken: "def")) },
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
