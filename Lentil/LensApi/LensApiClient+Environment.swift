// Lentil

import Apollo
import ComposableArchitecture
import SwiftUI
import UIKit
import web3


extension LensApi: DependencyKey {
  static let liveValue = LensApi(
    authenticationChallenge: { address in
      try await run(
        query: ChallengeQuery(request: .init(address: address)),
        mapResult: { data in
          QueryResult(data: data.challenge.text)
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
            data: data.explorePublications.items.compactMap(Publication.from),
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
              Publication.from($0, child: publication)
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
          if let defaultProfile = Profile.from(data.defaultProfile) {
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
          QueryResult(data: Profile.from(data.profiles))
        }
      )
    },
    getProfilePicture: { url in
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
  
  // TODO: Remove after fully changed to Reducer Protocol
  static let live = liveValue
  
#if DEBUG
  static let previewValue = LensApi(
    authenticationChallenge: { _ in QueryResult(data: "Sign this message!") },
    trendingPublications: { _, _, _, _ in return QueryResult(data: mockPublications) },
    commentsOfPublication: { _ in QueryResult(data: mockComments) },
    reactionsOfPublication: { publication in QueryResult(data: mockPosts.first(where: { $0.id == publication.id })!) },
    defaultProfile: { _ in QueryResult(data: mockProfiles[2]) },
    profiles: { _ in QueryResult(data: mockProfiles) },
    getProfilePicture: { _ in throw ApiError.requestFailed },
    broadcast: { _, _ in MutationResult(data: .success(.init(txnHash: "abc", txnId: "def"))) },
    authenticate: { _, _ in MutationResult(data: AuthenticationTokens(accessToken: "abc", refreshToken: "def")) },
    getDefaultProfileTypedData: { _ in MutationResult(data: TypedDataResult(id: "abc", expires: Date().addingTimeInterval(60 * 60), typedData: mockTypedData)) }
  )
  
  // TODO: Remove after fully changed to Reducer Protocol
  static let mock = previewValue
#endif
}


// Reducer protocol dependencies

extension DependencyValues {
  var lensApi: LensApi {
    get { self[LensApi.self] }
    set { self[LensApi.self] = newValue }
  }
}
