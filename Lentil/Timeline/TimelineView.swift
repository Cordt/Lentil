// Lentil

import ComposableArchitecture
import SwiftUI


struct TimelineView: View {
  let store: Store<Timeline.State, Timeline.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      List {
        Group {
          ForEachStore(
            self.store.scope(
              state: \.posts,
              action: Timeline.Action.post)
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
      .navigationTitle("Timeline")
      .listStyle(.plain)
      .refreshable { viewStore.send(.refreshFeed) }
      .task { viewStore.send(.refreshFeed) }
    }
  }
}


struct TrendingView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TimelineView(
        store: .init(
          initialState: .init(),
          reducer: Timeline()
        )
      )
    }
  }
}
