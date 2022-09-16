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
}

enum AppAction: Equatable {
  case refreshFeed
  case fetchPublications
  case publicationsResponse(TaskResult<[Post]>)
  
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
        return .concatenate(
          .cancel(id: CancelFetchPublicationsID.self),
          .init(value: .fetchPublications)
        )
        
      case .fetchPublications:
        return .task {
          await .publicationsResponse(
            TaskResult {
              return try await env.lensApi.getPublications(10, .latest, [.post])
            }
          )
        }
        .cancellable(id: CancelFetchPublicationsID.self)
        
      case .publicationsResponse(let response):
        switch response {
          case .success(let result):
            state.posts.append(
              contentsOf: result
                .sorted { $0.createdAt < $1.createdAt }
                .map { PostState(post: $0) }
            )
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
          ForEachStore(
            self.store.scope(
              state: \.posts,
              action: AppAction.post)
          ) {
            PostView(store: $0)
          }
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())
        }
      }
      .listStyle(.plain)
      .scrollIndicators(.hidden)
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
