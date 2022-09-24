// Lentil

import Apollo
import Foundation
import SwiftUI


class Network {
  static let shared = Network()
  
  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://api-mumbai.lens.dev/")!)
}

struct QueryResult<Result: Equatable>: Equatable {
  var data: Result
  var cursorToNext: String?
}

struct LensApi {
  var trendingPublications: @Sendable (
    _ limit: Int,
    _ cursor: String?,
    _ sortCriteria: PublicationSortCriteria,
    _ publicationTypes: [PublicationTypes]
  ) async throws -> QueryResult<[Publication]>
  
  var commentsOfPublication: @Sendable (
    _ publication: Publication
  ) async throws -> QueryResult<[Publication]>
  
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
    trendingPublications: { limit, cursor, sortCriteria, publicationTypes in
      try await withCheckedThrowingContinuation { continuation in
        let _ = Network.shared.apollo.fetch(
          query: ExplorePublicationsQuery(
            request: ExplorePublicationRequest(
              limit: "\(limit)",
              cursor: cursor,
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
                let errorMessage = apiData.errors!
                  .map { $0.localizedDescription }
                  .joined(separator: "\n")
                print("[WARN] GraphQL error: \(errorMessage)")
                continuation.resume(throwing: ApiError.graphQLError)
                return
              }
              
              let publications = data.explorePublications.items.compactMap(Publication.from)
              continuation.resume(
                returning: QueryResult(
                  data: publications,
                  cursorToNext: data.explorePublications.pageInfo.next
                )
              )
              return
              
            case let .failure(error):
              print("[WARN] GraphQL error: \(error)")
              continuation.resume(throwing: ApiError.requestFailed)
              return
          }
        }
      }
    },
    commentsOfPublication: { publication in
      try await withCheckedThrowingContinuation { continuation in
        let _ = Network.shared.apollo.fetch(
          query: PublicationsQuery(
            request: PublicationsQueryRequest(
              commentsOf: publication.id
            )
          )
        ) { result in
          switch result {
            case let .success(apiData):
              guard apiData.errors == nil,
                    let data = apiData.data
              else {
                let errorMessage = apiData.errors!
                  .map { $0.localizedDescription }
                  .joined(separator: "\n")
                print("[WARN] GraphQL error: \(errorMessage)")
                continuation.resume(throwing: ApiError.graphQLError)
                return
              }
              
              let publications = data.publications.items.compactMap {
                Publication.from($0, child: publication)
              }
              continuation.resume(
                returning: QueryResult(data: publications)
              )
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
    trendingPublications: { _, _, _, _ in
      return QueryResult(data: mockPublications)
    },
    commentsOfPublication: { _ in QueryResult(data: mockComments) },
    getProfilePicture: { _ in throw ApiError.requestFailed }
  )
  #endif
}
