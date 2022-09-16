// Lentil

import Apollo
import Foundation
import SwiftUI


class Network {
  static let shared = Network()
  
  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://api-mumbai.lens.dev/")!)
}

struct LensApi {
  var getPublications: @Sendable (
    _ limit: Int,
    _ sortCriteria: PublicationSortCriteria,
    _ publicationTypes: [PublicationTypes]
  ) async throws -> [Post]
  
  var getProfilePicture: @Sendable (
    _ from: URL
  ) async throws -> Image
}

enum ApiError: Error, Equatable {
  case requestFailed
  case graphQLError
}

extension LensApi {
  static let live = LensApi(
    getPublications: { limit, sortCriteria, publicationTypes in
      try await withCheckedThrowingContinuation { continuation in
        let _ = Network.shared.apollo.fetch(
          query: ExplorePublicationsQuery(
            request: ExplorePublicationRequest(
              limit: "\(limit)",
              sortCriteria: sortCriteria,
              publicationTypes: publicationTypes
            )
          )
        ) { result in
          switch result {
            case let .success(apiData):
              guard apiData.errors == nil,
                    let data = apiData.data
              else {
                continuation.resume(throwing: ApiError.graphQLError)
                return
              }
              
              let posts = data.explorePublications.items.compactMap { item -> Post? in
                guard
                  let postFields = item.asPost?.fragments.postFields,
                  let name = postFields.metadata.fragments.metadataOutputFields.name,
                  let content = postFields.metadata.fragments.metadataOutputFields.content,
                  let createdDate = date(from: postFields.createdAt),
                  let profileFields = item.asPost?.fragments.postFields.profile.fragments.profileFields,
                  let profilePictureUrlString = profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
                  let profilePictureUrl = URL(string: profilePictureUrlString)
                else { return nil }
                return Post(
                  id: postFields.id,
                  createdAt: createdDate,
                  name: name,
                  content: content,
                  creatorProfile: .init(
                    id: profileFields.id,
                    name: profileFields.name,
                    handle: profileFields.handle,
                    isFollowedByMe: profileFields.isFollowedByMe,
                    profilePictureUrl: profilePictureUrl
                  )
                )
              }
              continuation.resume(returning: posts)
              return
              
            case let .failure(error):
              continuation.resume(throwing: ApiError.requestFailed)
              return
          }
        }
      }
    },
    getProfilePicture: { url in
      let (data, _) = try await URLSession.shared.data(from: url)
      guard let uiImage = UIImage(data: data)
      else { throw ApiError.requestFailed }
      return Image(uiImage: uiImage)
    }
  )
  
  #if DEBUG
  static let mock = LensApi(
    getPublications: { _, _, _ in
      return mockPosts
    },
    getProfilePicture: { _ in Image(systemName: "person.crop.circle.fill")}
  )
  #endif
}
