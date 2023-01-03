// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import Foundation


class Network {
  static let shared = Network()
  
  private(set) lazy var autheticatedClient = {
    let client = URLSessionClient()
    let cache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: cache)
    let provider = NetworkInterceptorProvider(client: client, store: store, setup: [.tokenAdding, .requestLogging])
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: URL(string: LentilEnvironment.shared.baseUrl)!)
    
    return ApolloClient(networkTransport: transport, store: store)
  }()
  
  private(set) lazy var client = {
    let client = URLSessionClient()
    let cache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: cache)
    let provider = NetworkInterceptorProvider(client: client, store: store, setup: [.requestLogging])
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: URL(string: LentilEnvironment.shared.baseUrl)!)
    
    return ApolloClient(networkTransport: transport, store: store)
  }()
}

struct Cursor: Equatable {
  var prev: String?
  var next: String?
  var exhausted: Bool { self.prev != nil && next == nil }
}

struct PaginatedResult<Result: Equatable>: Equatable {
  var data: Result
  var cursor: Cursor
}

extension RelayErrorReasons: Error {}
struct RelayerResult: Equatable {
  var txnHash: String
  var txnId: String
}

struct AuthenticationTokens: Equatable {
  var accessToken: String
  var refreshToken: String
}

struct TypedDataResult: Equatable {
  var id: String
  var expires: Date
  var typedData: Data
}

struct Challenge: Equatable {
  var message: String
  var expires: Date
}

enum ApiError: Error, Equatable {
  case unauthenticated
  
  case requestFailed
  case graphQLError
  case cannotParseResponse
}

struct LensApi {
  
  // MARK: API Queries
  
  var authenticationChallenge: @Sendable (
    _ address: String
  ) async throws -> Challenge
  
  var verify: @Sendable (
  ) async throws -> Bool
  
  var publication: @Sendable (
    _ txHash: String
  ) async throws -> Model.Publication?
  
  var publications: @Sendable (
    _ limit: Int,
    _ cursor: String?,
    _ profileId: String,
    _ publicationTypes: [PublicationTypes],
    _ reactionsForProfile: String?
  ) async throws -> PaginatedResult<[Model.Publication]>
  
  var explorePublications: @Sendable (
    _ limit: Int,
    _ cursor: String?,
    _ sortCriteria: PublicationSortCriteria,
    _ publicationTypes: [PublicationTypes],
    _ reactionsForProfile: String?
  ) async throws -> PaginatedResult<[Model.Publication]>
  
  var feed: @Sendable (
    _ limit: Int,
    _ cursor: String?,
    _ profileId: String,
    _ reactionsForProfile: String?
  ) async throws -> PaginatedResult<[Model.Publication]>
  
  var commentsOfPublication: @Sendable (
    _ publication: Model.Publication,
    _ reactionsForProfile: String?
  ) async throws -> PaginatedResult<[Model.Publication]>
  
  var defaultProfile: @Sendable (
    _ ethereumAddress: String
  ) async throws -> Model.Profile
  
  var profile: @Sendable (
    _ forHandle: String
  ) async throws -> Model.Profile?
  
  var profiles: @Sendable (
    _ ownedBy: String
  ) async throws -> PaginatedResult<[Model.Profile]>
  
  var fetchImage: @Sendable (
    _ from: URL
  ) async throws -> Data
  
  // MARK: API Mutations
  
  var broadcast: @Sendable (
    _ broadcastId: String,
    _ signature: String
  ) async throws -> Result<RelayerResult, RelayErrorReasons>
  
  var authenticate: @Sendable (
    _ address: String,
    _ signature: String
  ) async throws -> Void
  
  var refreshAuthentication: @Sendable (
  ) async throws -> Void
  
  var createPost: @Sendable (
    _ profileId: String,
    _ contentUri: String
  ) async throws -> Result<RelayerResult, RelayErrorReasons>
  
  var createComment: @Sendable (
    _ profileId: String,
    _ publicationId: String,
    _ contentUri: String
  ) async throws -> Result<RelayerResult, RelayErrorReasons>
  
  var addReaction: @Sendable (
    _ profileId: String,
    _ reaction: ReactionTypes,
    _ publicationId: String
  ) async throws -> Void
  
  var removeReaction: @Sendable (
    _ profileId: String,
    _ reaction: ReactionTypes,
    _ publicationId: String
  ) async throws -> Void
  
  var createMirror: @Sendable (
    _ profileId: String,
    _ publicationId: String
  ) async throws -> Result<RelayerResult, RelayErrorReasons>
  
  var getDefaultProfileTypedData: @Sendable (
    _ profileId: String
  ) async throws -> TypedDataResult
}
