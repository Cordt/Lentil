// Lentil

import ComposableArchitecture


struct Timeline: ReducerProtocol {
  struct State: Equatable {
    var posts: IdentifiedArrayOf<Post.State> = []
    var cursorToNext: String?
  }
  
  enum Action: Equatable {
    case refreshFeed
    case fetchPublications
    case publicationsResponse(TaskResult<QueryResult<[Model.Publication]>>)
    case loadMore
    
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      enum CancelFetchPublicationsID {}
      
      switch action {
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
                return try await lensApi.trendingPublications(5, cursor, .topCommented, [.post])
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
              print("[WARN] Could not fetch publications from API: \(error)")
              return .none
          }
          
        case .post:
          return .none
      }
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
