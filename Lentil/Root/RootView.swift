//
//  RootView.swift
//  Lentil
//
//  Created by Cordt Zermin on 10.09.22.
//

import ComposableArchitecture
import SwiftUI


struct RootView: View {
  @Dependency(\.navigationApi) var navigationApi
  let store: Store<Root.State, Root.Action>
  
  @ViewBuilder
  func handle(_ destinationPath: DestinationPath) -> some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch destinationPath.destination {
        case .publication:
          if viewStore.posts[id: destinationPath.id] != nil {
            let store: Store<Post.State?, Post.Action> = self.store.scope(
              state: {
                guard let postState = $0.posts[id: destinationPath.id]
                else { return nil }
                return postState
              },
              action: { Root.Action.post(id: destinationPath.id, action: $0) }
            )
            IfLetStore(store, then: PostDetailView.init)
          }
          else if viewStore.comments[id: destinationPath.id] != nil {
            let store: Store<Post.State?, Post.Action> = self.store.scope(
              state: {
                guard let commentState = $0.comments[id: destinationPath.id]
                else { return nil }
                return commentState
              },
              action: { Root.Action.comment(id: destinationPath.id, action: $0) }
            )
            IfLetStore(store, then: PostDetailView.init)
          }
          
        case .profile:
          let store: Store<Profile.State?, Profile.Action> = self.store.scope(
            state: {
              guard let profileState = $0.profiles[id: destinationPath.id]
              else { return nil }
              return profileState
            },
            action: { Root.Action.profile(id: destinationPath.id, action: $0) }
          )
          IfLetStore(store, then: ProfileView.init)
          
        case .showNotifications:
          IfLetStore(
            self.store.scope(
              state: \.showNotifications,
              action: Root.Action.showNotifications
            ),
            then: NotificationsView.init
          )
          
        case .createPublication:
          IfLetStore(
            self.store.scope(
              state: \.createPublication,
              action: Root.Action.createPublication
            ),
            then: CreatePublicationView.init
          )
          
        case .imageDetail:
          if let imageURL = viewStore.imageDetail {
            ImageView(url: imageURL) {
              self.navigationApi.remove(destinationPath)
            }
          }
          
        case .conversation:
          IfLetStore(
            self.store.scope(
              state: \.conversation,
              action: Root.Action.conversation
            ),
            then: ConversationView.init
          )
      }
    }
  }
  
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
          NavigationStack(path: self.navigationApi.pathBinding()) {
            TimelineView(
              store: self.store.scope(
                state: \.timelineState,
                action: Root.Action.timelineAction
              )
            )
            .toolbarBackground(Theme.Color.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: DestinationPath.self, destination: self.handle)
          }
          .tabItem { Label("Feed", systemImage: "house") }
          .tag(Root.State.TabDestination.feed)
          
          NavigationStack(path: self.navigationApi.pathBinding()) {
            ConversationsView(
              store: self.store.scope(
                state: \.conversationsState,
                action: Root.Action.conversationsAction
              )
            )
            .toolbarBackground(Theme.Color.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: DestinationPath.self, destination: self.handle)
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(
        initialState: Root.State(
          isLoading: true,
          timelineState: .init()
        ),
        reducer: Root()
      )
    )
  }
}
