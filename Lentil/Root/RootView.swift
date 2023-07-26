// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI


struct RootView: View {
  let store: StoreOf<Root>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      if viewStore.isLoading {
        ZStack {
          Theme.Color.primary
            .ignoresSafeArea()
          
          VStack {
            Text("lentil")
              .font(highlight: .largeTitle, color: Theme.Color.white)
            ProgressView(viewStore.loadingText)
              .transition(.scale)
          }
        }
        .onAppear { viewStore.send(.loadingScreenAppeared) }
        .onDisappear { viewStore.send(.loadingScreenDisappeared) }
      }
      else {
        TabView {
          NavigationStackStore(self.store.scope(state: \.lensPath, action: { .lensPath($0) })) {
            TimelineView(
              store: self.store.scope(
                state: \.timelineState,
                action: Root.Action.timelineAction
              )
            )
            .toolbarBackground(Theme.Color.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            
          } destination: { state in
            switch state {
              case .publication:
                CaseLet(
                  /Root.LensPath.State.publication,
                   action: Root.LensPath.Action.publication,
                   then: PostView.init(store:))
                
              case .profile:
                CaseLet(
                  /Root.LensPath.State.profile,
                   action: Root.LensPath.Action.profile,
                   then: ProfileView.init(store:)
                )
              case .showNotifications:
                CaseLet(
                  /Root.LensPath.State.showNotifications,
                   action: Root.LensPath.Action.showNotifications,
                   then: NotificationsView.init(store:)
                )
                
              case .createPublication:
                CaseLet(
                  /Root.LensPath.State.createPublication,
                   action: Root.LensPath.Action.createPublication,
                   then: CreatePublicationView.init(store:)
                )
            }
          }
          .tabItem { Label("Feed", systemImage: "house") }
          .tag(Root.State.TabDestination.feed)
          
          NavigationStackStore(self.store.scope(state: \.xmtpPath, action: { .xmtpPath($0) })) {
            ConversationsView(
              store: self.store.scope(
                state: \.conversationsState,
                action: Root.Action.conversationsAction
              )
            )
            .toolbarBackground(Theme.Color.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            
          } destination: { state in
            switch state {
              case .conversation:
                CaseLet(
                  /Root.XMTPPath.State.conversation,
                   action: Root.XMTPPath.Action.conversation,
                   then: ConversationView.init(store:)
                )
            }
          }
          .tabItem { Label("Messages", systemImage: "envelope") }
          .tag(Root.State.TabDestination.messages)
          
        }
        .tint(Theme.Color.primary)
        .onAppear { viewStore.send(.rootAppeared) }
        .onDisappear { viewStore.send(.rootDisappeared) }
      }
    }
  }
}
