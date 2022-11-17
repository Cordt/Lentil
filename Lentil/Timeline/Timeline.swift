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
    case refreshFeed
    case fetchPublications
    case publicationsResponse(TaskResult<QueryResult<[Model.Publication]>>)
    case loadMore
    
    case walletConnect(Wallet.Action)
    case post(id: Post.State.ID, action: Post.Action)
  }
  
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
          state.userProfile = profileStorageApi.load()
          return Effect(value: .refreshFeed)
          
        case .refreshFeed:
          state.cursorToNext = nil
          return .concatenate(
            .cancel(id: CancelFetchPublicationsID.self),
            .init(value: .fetchPublications)
          )
          
        case .fetchPublications:
          return .task { [cursor = state.cursorToNext, id = state.userProfile?.id] in
            await .publicationsResponse(
              TaskResult {
                return try await lensApi.trendingPublications(50, cursor, .topCommented, [.post, .comment], id)
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
