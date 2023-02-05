// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct ConversationsView: View {
  let store: StoreOf<Conversations>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Group {
        switch viewStore.connectionStatus {
          case .notConnected:
            VStack(spacing: 30) {
              Text("Connect to XMTP")
                .font(style: .largeHeadline)
              
              Text("In order to use messaging, you need to sign a transaction with your wallet.")
                .font(style: .bodyDetailed)
                .multilineTextAlignment(.center)
              
              LentilButton(title: "Connect now", kind: .primary) {
                viewStore.send(.connectTapped)
              }
            }
            .padding(.horizontal, 60)
            
          case .connected:
            VStack(spacing: 30) {
              Text("Connect to XMTP")
                .font(style: .largeHeadline)
              
              Text("In order to use messaging, you need to sign a transaction with your wallet.")
                .font(style: .bodyDetailed)
                .multilineTextAlignment(.center)
              
              LentilButton(title: "Sign with Wallet", kind: .primary) {
                viewStore.send(.signInTapped)
              }
            }
            .padding(.horizontal, 60)
            .onDisappear { viewStore.send(.walletConnectDidDisappear) }
            
          case .signedIn:
            ScrollView(axes: .vertical, showsIndicators: false) {
              LazyVStack(alignment: .leading) {
                ForEachStore(
                  self.store.scope(
                    state: \.conversations,
                    action: Conversations.Action.conversation
                  )
                ) { store in
                  ConversationRowView(store: store)
                }
              }
            }
            .padding(.horizontal)
            .refreshable { await viewStore.send(.didRefresh).finish() }
        }
      }
      .sheet(
        unwrapping: viewStore.binding(
          get: \.createConversation,
          send: Conversations.Action.setCreateConversation
        ), content: { _ in
          IfLetStore(self.store.scope(
            state: \.createConversation,
            action: Conversations.Action.createConversation
          )) { store in
            CreateConversationView(store: store)
          }
        }
      )
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Messages")
            .font(style: .largeHeadline, color: Theme.Color.white)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          if case .signedIn = viewStore.connectionStatus {
            Button {
              viewStore.send(.createConversationTapped)
            } label: {
              Icon.create.view(.xlarge)
                .foregroundColor(Theme.Color.white)
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.didAppear).finish() }
      .onDisappear { viewStore.send(.didDisappear) }
    }
  }
}

#if DEBUG
struct ConversationsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ConversationsView(
        store: .init(
          initialState: .init(
            conversations: []
          ),
          reducer: Conversations()
        )
      )
      .toolbarBackground(Theme.Color.primary, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }
}
#endif
