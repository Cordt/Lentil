// Lentil

import Apollo
import Foundation
import SwiftUI
import web3


class Network {
  static let shared = Network()
  
  private(set) lazy var autheticatedClient = {
    let client = URLSessionClient()
    let cache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: cache)
    let provider = NetworkInterceptorProvider(client: client, store: store, setup: [.tokenAdding, .requestLogging])
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: URL(string: ProcessInfo.processInfo.environment["BASE_URL"]!)!)
    
    return ApolloClient(networkTransport: transport, store: store)
  }()
  
  private(set) lazy var client = {
    let client = URLSessionClient()
    let cache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: cache)
    let provider = NetworkInterceptorProvider(client: client, store: store, setup: [.requestLogging])
    let transport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: URL(string: ProcessInfo.processInfo.environment["BASE_URL"]!)!)
    
    return ApolloClient(networkTransport: transport, store: store)
  }()
}

struct QueryResult<Result: Equatable>: Equatable {
  var data: Result
  var cursorToNext: String?
}

struct MutationResult<Result: Equatable>: Equatable {
  var data: Result
}

extension RelayErrorReasons: Error {}
struct Broadcast: Equatable {
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
  var typedData: TypedData
}

enum ApiError: Error, Equatable {
  case requestFailed
  case graphQLError
  case cannotParseResponse
}

struct LensApi {
  
  // MARK: API Queries
  
  var authenticationChallenge: @Sendable (
    _ address: String
  ) async throws -> QueryResult<String>
  
  var trendingPublications: @Sendable (
    _ limit: Int,
    _ cursor: String?,
    _ sortCriteria: PublicationSortCriteria,
    _ publicationTypes: [PublicationTypes]
  ) async throws -> QueryResult<[Model.Publication]>
  
  var commentsOfPublication: @Sendable (
    _ publication: Model.Publication
  ) async throws -> QueryResult<[Model.Publication]>
  
  var reactionsOfPublication: @Sendable (
    _ publication: Model.Publication
  ) async throws -> QueryResult<Model.Publication>
  
  var defaultProfile: @Sendable (
    _ ethereumAddress: String
  ) async throws -> QueryResult<Model.Profile>
  
  var profiles: @Sendable (
    _ ownedBy: String
  ) async throws -> QueryResult<[Model.Profile]>
  
  var getProfilePicture: @Sendable (
    _ from: URL
  ) async throws -> Image
  
  // MARK: API Mutations
  
  var broadcast: @Sendable (
    _ broadcastId: String,
    _ signature: String
  ) async throws -> MutationResult<Result<Broadcast, RelayErrorReasons>>
  
  var authenticate: @Sendable (
    _ address: String,
    _ signature: String
  ) async throws -> MutationResult<AuthenticationTokens>
  
  var getDefaultProfileTypedData: @Sendable (
    _ profileId: String
  ) async throws -> MutationResult<TypedDataResult>
}
