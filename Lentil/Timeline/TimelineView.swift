// Lentil
// Created by Laura and Cordt Zermin

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
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if let userProfile = viewStore.userProfile {
            NavigationLink {
              // TODO: Load and open user's profile
            } label: {
              profileGradient(from: userProfile.handle)
                .frame(width: 32, height: 32)
            }
          }
          else {
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
        }
        ToolbarItem(placement: .principal) {
          Text("lentil")
            .font(highlight: .largeHeadline, color: Theme.Color.white)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(.plain)
      .refreshable { await viewStore.send(.refreshFeed).finish() }
      .task { viewStore.send(.timelineAppeared) }
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
      .toolbarBackground(Theme.Color.primary, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }
}
