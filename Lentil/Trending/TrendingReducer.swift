// Lentil

import ComposableArchitecture


struct TrendingState: Equatable {
  var posts: IdentifiedArrayOf<PostState> = []
  var cursorToNext: String?
}

enum TrendingAction: Equatable {
  case refreshFeed
  case fetchPublications
  case publicationsResponse(TaskResult<QueryResult<[Publication]>>)
  case loadMore
  
  case post(id: PostState.ID, action: PostAction)
}

let trendingReducer = Reducer<TrendingState, TrendingAction, RootEnvironment>.combine(
  postReducer.forEach(
    state: \TrendingState.posts,
    action: /TrendingAction.post,
    environment: { $0 }
  ),
  
  Reducer { state, action, env in
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
              return try await env.lensApi.trendingPublications(5, cursor, .latest, [.post])
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
                .map { PostState(post: .init(publication: $0)) }
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
)
