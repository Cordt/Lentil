// Lentil

import Apollo
import Foundation


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
                  let createdDate = date(from: postFields.createdAt)
                else { return nil }
                return Post(
                  id: postFields.id,
                  createdAt: createdDate,
                  name: name,
                  content: content
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
    }
  )
}
