// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SDWebImageSwiftUI
import SwiftUINavigation
import SwiftUI


struct TimelineView: View {
  let store: Store<Timeline.State, Timeline.Action>
  
  var footer: some View {
    WithViewStore(self.store, observe: { $0.loadingInFlight }) { viewStore in
      HStack {
        Spacer()
        if viewStore.state {
          ProgressView()
        }
        Spacer()
      }
      .padding(.top, 10)
    }
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollViewReader { proxy in
        ScrollView(axes: .vertical, showsIndicators: false) {
          LazyVStack(alignment: .leading) {
            ForEachStore(
              self.store.scope(
                state: \.posts,
                action: Timeline.Action.post
              )
            ) { store in
              PostView(store: store)
            }
            self.footer
          }
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            if let userProfile = viewStore.userProfile {
              Button {
                viewStore.send(.ownProfileTapped)
              } label: {
                if let url = viewStore.showProfile?.profile.profilePictureUrl {
                  WebImage(url: url)
                    .resizable()
                    .placeholder {
                      profileGradient(from: userProfile.handle)
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                }
                else {
                  profileGradient(from: userProfile.handle)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                }
              }
            }
            else {
              Button {
                viewStore.send(.connectWalletTapped)
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
              HStack {
                Button {
                  viewStore.send(.createPublicationTapped)
                } label: {
                  Icon.add.view(.xlarge)
                    .foregroundColor(Theme.Color.white)
                }
                
//                Button {
//                  viewStore.send(.showNotificationsTapped)
//                } label: {
//                  Icon.bell.view(.xlarge)
//                    .foregroundColor(Theme.Color.white)
//                }
              }
            }
          }
        }
        .toastView(
          toast: viewStore.binding(
            get: \.isIndexing,
            send: { Timeline.Action.updateIndexingToast($0) }
          )
        )
        .navigationDestination(
          unwrapping: viewStore.binding(
            get: \.connectWallet,
            send: Timeline.Action.setConnectWallet
          ),
          destination: { _ in
            IfLetStore(self.store.scope(
              state: \.connectWallet,
              action: Timeline.Action.connectWallet
            )) { WalletView(store: $0) }
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
        .onAppear { viewStore.send(.timelineAppeared) }
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
