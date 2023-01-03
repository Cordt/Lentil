// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import Foundation

extension LensApi {
  enum NetworkClient {
    case authenticated, unauthenticated
    
    fileprivate var client: ApolloClient {
      switch self {
        case .authenticated:
          return Network.shared.autheticatedClient
          
        case .unauthenticated:
          return Network.shared.client
      }
    }
  }
  
  static let queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)
  
  static func run<Query: GraphQLQuery, Output: Equatable>(
    networkClient: NetworkClient = .unauthenticated,
    query: Query,
    cachePolicy: CachePolicy = .fetchIgnoringCacheData,
    mapResult: @escaping (Query.Data) throws -> Output
  ) async throws -> Output {
    try await runRefreshing(networkClient: networkClient) {
      try await withCheckedThrowingContinuation { continuation in
        networkClient.client.fetch(
          query: query,
          cachePolicy: cachePolicy,
          queue: self.queue
        ) { result in
          transform(
            continuation: continuation,
            result: result,
            mapResult: mapResult
          )
        }
      }
    }
  }
  
  static func run<Mutation: GraphQLMutation, Output: Equatable>(
    networkClient: NetworkClient = .unauthenticated,
    mutation: Mutation,
    mapResult: @escaping (Mutation.Data) throws -> Output
  ) async throws -> Output {
    try await self.runRefreshing(networkClient: networkClient) {
      try await withCheckedThrowingContinuation { continuation in
        networkClient.client.perform(
          mutation: mutation,
          queue: self.queue
        ) { result in
          transform(
            continuation: continuation,
            result: result,
            mapResult: mapResult
          )
        }
      }
    }
  }
  
  static func run<Mutation: GraphQLMutation>(
    networkClient: NetworkClient = .unauthenticated,
    mutation: Mutation,
    mapResult: @escaping (Mutation.Data) throws -> Void
  ) async throws -> Void {
    try await self.runRefreshing(networkClient: networkClient) {
      try await withCheckedThrowingContinuation { continuation in
        networkClient.client.perform(
          mutation: mutation,
          queue: self.queue
        ) { result in
          transform(continuation: continuation, result: result, mapResult: mapResult)
        }
      }
    }
  }
  
  static func run<Mutation: GraphQLMutation>(
    networkClient: NetworkClient = .unauthenticated,
    mutation: Mutation
  ) async throws -> Void {
    try await self.runRefreshing(networkClient: networkClient) {
      try await withCheckedThrowingContinuation { continuation in
        networkClient.client.perform(
          mutation: mutation,
          queue: self.queue
        ) { result in
          transform(continuation: continuation, result: result, mapResult: { _ in })
        }
      }
    }
  }
  
  fileprivate static func runRefreshing<Output: Equatable>(
    networkClient: NetworkClient,
    _ work: () async throws -> PaginatedResult<Output>
  ) async throws -> PaginatedResult<Output> {
    do {
      return try await work()
    } catch ApiError.unauthenticated {
      do {
        try await self.refresh(networkClient: networkClient)
        return try await work()
      }
      catch let error {
        try AuthTokenStorage.delete()
        ProfileStorage.remove()
        log("Failed to refresh access token, removing tokens", level: .debug, error: error)
        throw ApiError.unauthenticated
      }
    }
  }
  
  fileprivate static func runRefreshing<Output: Equatable>(
    networkClient: NetworkClient,
    _ work: () async throws -> Output
  ) async throws -> Output {
    do {
      return try await work()
    } catch ApiError.unauthenticated {
      do {
        try await self.refresh(networkClient: networkClient)
        return try await work()
      }
      catch let error {
        try AuthTokenStorage.delete()
        ProfileStorage.remove()
        log("Failed to refresh access token, removing tokens", level: .debug, error: error)
        throw ApiError.unauthenticated
      }
    }
  }
  
  fileprivate static func runRefreshing(
    networkClient: NetworkClient,
    _ work: () async throws -> Void
  ) async throws {
    do {
      try await work()
    } catch ApiError.unauthenticated {
      do {
        try await self.refresh(networkClient: networkClient)
        try await work()
      }
      catch let error {
        try AuthTokenStorage.delete()
        ProfileStorage.remove()
        log("Failed to refresh access token, removing tokens", level: .debug, error: error)
        throw ApiError.unauthenticated
      }
    }
  }
  
  fileprivate static func refresh(
    networkClient: NetworkClient
  ) async throws {
    log("Trying to refresh access token", level: .info)
    let refreshToken = try AuthTokenStorage.load(token: .refresh)
    try await withCheckedThrowingContinuation { continuation in
      networkClient.client.perform(
        mutation: RefreshMutation(request: RefreshRequest(refreshToken: refreshToken)),
        queue: self.queue
      ) { result in
        transform(continuation: continuation, result: result) { data in
          try AuthTokenStorage.store(token: .access, key: data.refresh.accessToken)
          try AuthTokenStorage.store(token: .refresh, key: data.refresh.refreshToken)
        }
      }
    }
  }
  
  fileprivate static func transform<Data, Output>(
    continuation: CheckedContinuation<Output, Error>,
    result: Result<GraphQLResult<Data>, Error>,
    mapResult: (Data) throws -> Output
  ) {
    switch result {
      case .success(let apiData):
        guard apiData.errors == nil,
              let data = apiData.data
        else {
          let errorMessage = apiData.errors!
            .map { $0.localizedDescription }
            .joined(separator: "\n")
          
          // Explicitely handle authentication errors
          for error in apiData.errors! {
            if error.extensions?["code"] as? String == "UNAUTHENTICATED" {
              log("User not authenticated or access token not valid anymore: " + errorMessage , level: .debug)
              continuation.resume(throwing: ApiError.unauthenticated)
              return
            }
          }
          
          log("GraphQL error: " + errorMessage , level: .warn)
          continuation.resume(throwing: ApiError.graphQLError)
          return
        }
        
        do {
          continuation.resume(returning: try mapResult(data))
          return
        } catch let error {
          continuation.resume(throwing: error)
          return
        }
        
      case .failure(let error):
        log("GraphQL error: " , level: .warn, error: error)
        continuation.resume(throwing: ApiError.requestFailed)
        return
    }
  }
}
