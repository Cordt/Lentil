// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI
import XMTP


struct Conversations: ReducerProtocol {
  struct State: Equatable {
    enum ConnectionStatus: Equatable {
      case disconnected, connected
    }
    
    var connectionStatus: ConnectionStatus = .disconnected
    var conversations: IdentifiedArrayOf<ConversationRow.State> = []
  }
  
  enum Action: Equatable {
    case didAppear
    case didRefresh
    case loadConversations
    case conversationsResult(TaskResult<[XMTPConversation]>)
    case connectTapped
    case createMessageTapped
    
    case conversation(id: ConversationRow.State.ID, ConversationRow.Action)
  }
  
  @Dependency(\.xmtpConnector) var xmtpConnector
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear, .didRefresh:
          return Effect(value: .loadConversations)
          
        case .loadConversations:
          switch self.xmtpConnector.connectionStatus() {
            case .disconnected, .connecting:
              state.connectionStatus = .disconnected
              return .none

            case .connected:
              state.connectionStatus = .connected
              return .task {
                .conversationsResult(
                  await TaskResult {
                    await self.xmtpConnector.loadConversations()
                  }
                )
              }
              
            case .error(let error):
              log("Wallet connection ended in error state", level: .error, error: error)
              return .none
          }
          
        case .conversationsResult(.success(let conversations)):
          let conversationRows = conversations.map {
            ConversationRow.State(conversation: $0)
          }
          state.conversations = IdentifiedArrayOf(uniqueElements: conversationRows)
          return .none
          
        case .conversationsResult(.failure):
            return .none
          
        case .connectTapped:
          self.xmtpConnector.connectWallet()
          return .none
          
        case .createMessageTapped:
          return .none
          
        case .conversation:
          return .none
      }
    }
    .forEach(\.conversations, action: /Action.conversation) {
      ConversationRow()
    }
  }
}

struct ConversationsView: View {
  let store: Store<Conversations.State, Conversations.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Group {
        switch viewStore.connectionStatus {
          case .disconnected:
            VStack(spacing: 30) {
              Text("Connect to XMTP")
                .font(style: .largeHeadline)
              
              Text("In order to use messaging, you need to sign the transaction with XMTP.")
                .font(style: .bodyDetailed)
                .multilineTextAlignment(.center)
              
              LentilButton(title: "Connect now", kind: .primary) {
                viewStore.send(.connectTapped)
              }
            }
            .padding(.horizontal, 60)
            
          case .connected:
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
        }
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Messages")
            .font(style: .largeHeadline, color: Theme.Color.white)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          if viewStore.connectionStatus == .connected {
            Button {
              viewStore.send(.createMessageTapped)
            } label: {
              Icon.create.view(.xlarge)
                .foregroundColor(Theme.Color.white)
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .task { await viewStore.send(.didAppear).finish() }
      .refreshable { await viewStore.send(.didRefresh).finish() }
    }
  }
}

#if DEBUG
struct MessagesView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ConversationsView(
        store: .init(
          initialState: .init(
            conversations: [
              ConversationRow.State(
                conversation: MockData.conversations[0],
                profile: MockData.mockProfiles[0],
                lastMessage: MockData.conversationStubs[0]
              ),
              ConversationRow.State(
                conversation: MockData.conversations[1],
                lastMessage: MockData.conversationStubs[1]
              ),
              ConversationRow.State(
                conversation: MockData.conversations[2],
                lastMessage: MockData.conversationStubs[2]
              ),
            ]
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
