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
        NavigationStack(path: self.navigationApi.pathBinding()) {
          TimelineView(
            store: self.store.scope(
              state: \.timelineState,
              action: Root.Action.timelineAction
            )
          )
          .toolbarBackground(Theme.Color.primary, for: .navigationBar)
          .toolbarBackground(.visible, for: .navigationBar)
          .navigationDestination(for: DestinationPath.self) { destinationPath in
            switch destinationPath.destination {
              case .publication(let elementId):
                if viewStore.posts[id: elementId] != nil {
                  let store: Store<Post.State?, Post.Action> = self.store.scope(
                    state: {
                      guard let postState = $0.posts[id: elementId]
                      else { return nil }
                      return postState
                    },
                    action: { Root.Action.post(id: elementId, action: $0) }
                  )
                  IfLetStore(store, then: PostDetailView.init)
                }
                else if viewStore.comments[id: elementId] != nil {
                  let store: Store<Post.State?, Post.Action> = self.store.scope(
                    state: {
                      guard let commentState = $0.comments[id: elementId]
                      else { return nil }
                      return commentState
                    },
                    action: { Root.Action.comment(id: elementId, action: $0) }
                  )
                  IfLetStore(store, then: PostDetailView.init)
                }
                
              case .profile(let elementId):
                let store: Store<Profile.State?, Profile.Action> = self.store.scope(
                  state: {
                    guard let profileState = $0.profiles[id: elementId]
                    else { return nil }
                    return profileState
                  },
                  action: { Root.Action.profile(id: elementId, action: $0) }
                )
                IfLetStore(store, then: ProfileView.init)
                
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
            }
          }
        }
        .onAppear { viewStore.send(.rootScreenAppeared) }
        .onDisappear { viewStore.send(.rootScreenDisappeared) }
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
