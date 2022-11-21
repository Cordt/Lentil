// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct TimelineView: View {
  let store: Store<Timeline.State, Timeline.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView(.vertical, showsIndicators: false) {
        LazyVStack(alignment: .leading) {
          ForEachStore(
            self.store.scope(
              state: \.posts,
              action: Timeline.Action.post)
          ) { store in
            VStack(spacing: 0) {
              PostView(store: store)
            }
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if let userProfile = viewStore.userProfile {
            NavigationLink {
              IfLetStore(
                self.store.scope(
                  state: \.profile,
                  action: Timeline.Action.profile
                ), then: {
                  ProfileView(
                    store: $0
                  )
                }
              )
            } label: {
              if let profilePicture = viewStore.profile?.profilePicture {
                profilePicture
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 32, height: 32)
                  .clipShape(Circle())
              }
              else {
                profileGradient(from: userProfile.handle)
                  .frame(width: 32, height: 32)
              }
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
              Icon.link.view(.xlarge)
                .foregroundColor(Theme.Color.white)
            }
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text("lentil")
            .font(highlight: .largeHeadline, color: Theme.Color.white)
        }
        
        if viewStore.userProfile != nil {
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
              CreatePublicationView(
                store: self.store.scope(
                  state: \.createPublication,
                  action: Timeline.Action.createPublication
                )
              )
            } label: {
              Icon.add.view(.xlarge)
                .foregroundColor(Theme.Color.white)
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .refreshable { await viewStore.send(.refreshFeed).finish() }
      .task { viewStore.send(.timelineAppeared) }
    }
  }
}

#if DEBUG
struct TrendingView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TimelineView(
        store: .init(
          initialState: .init(
            profile: Profile.State(profile: MockData.mockProfiles[2])
          ),
          reducer: Timeline()
        )
      )
      .toolbarBackground(Theme.Color.primary, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }
}
#endif
