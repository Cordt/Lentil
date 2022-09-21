//
//  ContentView.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
  var posts: IdentifiedArrayOf<PostState> = []
  var cursorToNext: String?
}

enum AppAction: Equatable {
  case refreshFeed
  case fetchPublications
  case publicationsResponse(TaskResult<QueryResult<[Publication]>>)
  case loadMore
  
  case post(id: PostState.ID, action: PostAction)
}

struct AppEnvironment {
  let lensApi: LensApi
}

extension AppEnvironment {
  static var live: Self = .init(
    lensApi: .live
  )
  
  #if DEBUG
  static var mock: Self = .init(
    lensApi: .mock
  )
  #endif
}

let reducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  postReducer.forEach(
    state: \.posts,
    action: /AppAction.post,
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
              return try await env.lensApi.getPublications(10, cursor, .latest, [.post])
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
                .sorted { $0.createdAt < $1.createdAt }
                .map { PostState(post: $0) }
            )
            state.cursorToNext = result.cursorToNext
            return .none
            
          case .failure(let error):
            // Handle later...
            return .none
        }
        
      case .post:
        return .none
    }
  }
)

struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        List {
          Group {
            ForEachStore(
              self.store.scope(
                state: \.posts,
                action: AppAction.post)
            ) {
              PostView(store: $0)
            }
            HStack {
              Spacer()
              Button("Load more") {
                viewStore.send(.loadMore)
              }
              .buttonStyle(.borderedProminent)
              Spacer()
            }
          }
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())
        }
      }
      .listStyle(.plain)
      .scrollIndicators(.hidden)
      .refreshable {
        viewStore.send(.refreshFeed)
      }
      .task {
        viewStore.send(.refreshFeed)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(),
        reducer: reducer,
        environment: .mock
      )
    )
  }
}
