// Lentil

import Apollo
import Foundation


class Network {
  static let shared = Network()
  
  private(set) lazy var apollo = ApolloClient(url: URL(string: "https://api-mumbai.lens.dev/")!)
}

struct LensApi {
  var ping: @Sendable () async throws -> String
}

enum ApiError: Error, Equatable {
  case requestFailed
  case graphQLError
}

extension LensApi {
  static let live = LensApi(
    ping: {
      try await withCheckedThrowingContinuation { continuation in
        let _ = Network.shared.apollo.fetch(query: PingQuery()) { result in
          switch result {
            case let .success(apiData):
              guard apiData.errors == nil,
                    let data = apiData.data
              else {
                continuation.resume(throwing: ApiError.graphQLError)
                return
              }
              
              continuation.resume(returning: data.ping)
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
