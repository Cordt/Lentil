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
  
  static func run<Query: GraphQLQuery, Output: Equatable>(
    networkClient: NetworkClient = .unauthenticated,
    query: Query,
    mapResult: @escaping (Query.Data) throws -> QueryResult<Output>
  ) async throws -> QueryResult<Output> {
    
    try await withCheckedThrowingContinuation { continuation in
      networkClient.client.fetch(query: query) { result in
        transform(
          continuation: continuation,
          result: result,
          mapResult: mapResult
        )
      }
    }
  }
  
  static func run<Mutation: GraphQLMutation, Output: Equatable>(
    networkClient: NetworkClient = .unauthenticated,
    mutation: Mutation,
    mapResult: @escaping (Mutation.Data) throws -> MutationResult<Output>
  ) async throws -> MutationResult<Output> {
    try await withCheckedThrowingContinuation { continuation in
      networkClient.client.perform(mutation: mutation) { result in
        transform(
          continuation: continuation,
          result: result,
          mapResult: mapResult
        )
      }
    }
  }
  
  fileprivate static func transform<Data, Output>(
    continuation: CheckedContinuation<Output, Error>,
    result: Result<GraphQLResult<Data>, Error>,
    mapResult: @escaping (Data) throws -> Output
  ) {
    switch result {
      case .success(let apiData):
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
        
        do {
          continuation.resume(returning: try mapResult(data))
          return
        } catch let error {
          continuation.resume(throwing: error)
          return
        }
        
      case .failure(let error):
        print("[WARN] GraphQL error: \(error)")
        continuation.resume(throwing: ApiError.requestFailed)
        return
    }
  }
}
