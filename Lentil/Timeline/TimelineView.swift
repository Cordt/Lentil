// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUINavigation
import SwiftUI


struct TimelineView: View {
  let store: Store<Timeline.State, Timeline.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      
      ScrollViewReader { proxy in
        ScrollView(.vertical, showsIndicators: false) {
          LazyVStack(alignment: .leading) {
            if viewStore.indexingPost {
              HStack {
                Spacer()
                Text("Your publication is being indexed")
                  .font(style: .annotation, color: Theme.Color.greyShade3)
                Spacer()
              }
              .padding(.top, 10)
              .padding(.bottom, -10)
            }
            ForEachStore(
              self.store.scope(
                state: \.posts,
                action: Timeline.Action.post
              )
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
              Button {
                viewStore.send(.ownProfileTapped)
              } label: {
                if let profilePicture = viewStore.showProfile?.profilePicture {
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
              Button {
                viewStore.send(.setDestination(.connectWallet))
              } label: {
                Icon.link.view(.xlarge)
                  .foregroundColor(Theme.Color.white)
              }
            }
          }
          ToolbarItem(placement: .principal) {
            Button {
              viewStore.send(.lentilButtonTapped)
            } label: {
              Text("lentil")
                .font(highlight: .largeHeadline, color: Theme.Color.white)
            }
          }
          
          if viewStore.userProfile != nil {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button {
                viewStore.send(.createPublicationTapped)
              } label: {
                Icon.add.view(.xlarge)
                  .foregroundColor(Theme.Color.white)
              }
            }
          }
        }
        .navigationDestination(
          unwrapping: viewStore.binding(
            get: \.destination,
            send: Timeline.Action.setDestination
          ),
          case: /Timeline.Destination.connectWallet,
          destination: { _ in
            WalletView(
              store: self.store.scope(
                state: \.connectWallet,
                action: Timeline.Action.connectWallet
              )
            )
          }
        )
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(viewStore.scrollPosition.publisher) { position in
          withAnimation(.easeInOut(duration: 2.0)) {
            switch position {
              case .top(let id):
                proxy.scrollTo(id)
                viewStore.send(.scrollAnimationFinished)
            }
          }
        }
        .refreshable { await viewStore.send(.refreshFeed).finish() }
        .task { viewStore.send(.timelineAppeared) }
      }
    }
  }
}

#if DEBUG
struct TimelineView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TimelineView(
        store: .init(
          initialState: .init(
            showProfile: Profile.State(navigationId: "abc", profile: MockData.mockProfiles[2])
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
