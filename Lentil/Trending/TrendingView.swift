// Lentil

import ComposableArchitecture
import SwiftUI


struct TrendingView: View {
  let store: Store<TrendingState, TrendingAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      List {
        Group {
          ForEachStore(
            self.store.scope(
              state: \.posts,
              action: TrendingAction.post)
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
      .navigationTitle("Trending")
      .listStyle(.plain)
      .scrollIndicators(.hidden)
      .refreshable { viewStore.send(.refreshFeed) }
      .task { viewStore.send(.refreshFeed) }
    }
  }
}


struct TrendingView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TrendingView(
        store: .init(
          initialState: .init(),
          reducer: trendingReducer,
          environment: .mock
        )
      )
    }
  }
}
