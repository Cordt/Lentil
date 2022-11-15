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
          ) { store in
            PostView(store: store)
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
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationLink {
            WalletView(
              store: self.store.scope(
                state: \.walletConnect,
                action: Timeline.Action.walletConnect
              )
            )
          } label: {
            Image(systemName: "link")
              .foregroundColor(Theme.Color.white)
          }
        }
        ToolbarItem(placement: .principal) {
          Text("Lentil")
            .font(highlight: .largeHeadline, color: Theme.Color.white)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
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
    .navigationBarBackground()
  }
}
