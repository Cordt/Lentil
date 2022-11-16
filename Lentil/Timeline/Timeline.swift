// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture


struct Timeline: ReducerProtocol {
  struct State: Equatable {
    var userProfile: UserProfile? = nil
    var posts: IdentifiedArrayOf<Post.State> = []
    var cursorToNext: String?
    
    var walletConnect: Wallet.State = .init()
  }
  
  enum Action: Equatable {
    case timelineAppeared
    case refreshTokenResponse(_ accessToken: String, QueryResult<Bool>)
    case authTokenResponse(MutationResult<AuthenticationTokens>)
    case refreshFeed
    case fetchPublications
    case publicationsResponse(TaskResult<QueryResult<[Model.Publication]>>)
    case loadMore
    
    case walletConnect(Wallet.Action)
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.authTokenApi) var authTokenApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.walletConnect, action: /Action.walletConnect) {
        Wallet()
      }
    
    Reduce { state, action in
      enum CancelFetchPublicationsID {}
      
      switch action {
        case .timelineAppeared:
          do {
            // Verify that both access token and user are available
            guard try self.authTokenApi.checkFor(.access)
            else {
              self.profileStorageApi.remove()
              state.userProfile = nil
              return Effect(value: .refreshFeed)
            }
            let accessToken = try self.authTokenApi.load(.access)
            let refreshToken = try self.authTokenApi.load(.refresh)
            
            // Verify that the access token is still valid
            return .run { send in
              try await send(.refreshTokenResponse(refreshToken, self.lensApi.verify(accessToken)))
            }
          } catch let error {
            log("Failed to load user profile", level: .error, error: error)
            return .none
          }
          
        case .refreshTokenResponse(let refreshToken, let tokenIsValid):
          if tokenIsValid.data {
            state.userProfile = self.profileStorageApi.load()
            return .none
            
          } else {
            return .run { send in
              try await send(.authTokenResponse(self.lensApi.refreshAuthentication(refreshToken)))
            }
          }
          
        case .authTokenResponse(let tokens):
          do {
            try self.authTokenApi.store(.access, tokens.data.accessToken)
            try self.authTokenApi.store(.refresh, tokens.data.refreshToken)
            state.userProfile = self.profileStorageApi.load()
          } catch let error {
            log("Failed to store access tokens", level: .error, error: error)
          }
          return .none
          
        case .refreshFeed:
          state.cursorToNext = nil
          return .concatenate(
            .cancel(id: CancelFetchPublicationsID.self),
            .init(value: .fetchPublications)
          )
          
        case .fetchPublications:
          return .task { [cursor = state.cursorToNext] in
            await .publicationsResponse(
              TaskResult {
                return try await lensApi.trendingPublications(50, cursor, .topCommented, [.post, .comment])
              }
            )
          }
          .cancellable(id: CancelFetchPublicationsID.self)
          
        case .loadMore:
          return .concatenate(
            .cancel(id: CancelFetchPublicationsID.self),
            .init(value: .fetchPublications)
          )
          
        case .publicationsResponse(let response):
          switch response {
            case .success(let result):
              state.posts.append(
                contentsOf: result
                  .data
                  .filter { $0.typename == .post }
                  .sorted { $0.createdAt > $1.createdAt }
                  .map { Post.State(post: .init(publication: $0)) }
              )
              state.cursorToNext = result.cursorToNext
              return .none
              
            case .failure(let error):
              log("Could not fetch publications from API", level: .warn, error: error)
              return .none
          }
          
        case .walletConnect:
          return .none
          
        case .post:
          return .none
      }
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
