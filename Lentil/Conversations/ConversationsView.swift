// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI


struct Conversations: ReducerProtocol {
  struct State: Equatable {
    enum ConnectionStatus: Equatable {
      case notConnected, connected, signedIn
    }
    
    var connectionStatus: ConnectionStatus = .notConnected
    var createConversation: CreateConversation.State?
    var conversations: IdentifiedArrayOf<ConversationRow.State> = []
  }
  
  enum Action: Equatable {
    case didAppear
    case didRefresh
    case walletConnectDidAppear
    case walletConnectDidDisappear
    case didDisappear
    case listenOnWallet
    case updateConnectionStatus(State.ConnectionStatus)
    case signInTapped
    case loadConversations
    case conversationsResult(TaskResult<[XMTPConversation]>)
    case connectTapped
    case createMessageTapped
    
    case setCreateConversation(CreateConversation.State?)
    case createConversation(CreateConversation.Action)
    case conversation(id: ConversationRow.State.ID, ConversationRow.Action)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.walletConnect) var walletConnect
  @Dependency(\.xmtpConnector) var xmtpConnector
  @Dependency(\.uuid) var uuid
  enum WalletEventsCancellationID {}
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear, .didRefresh:
          return Effect(value: .loadConversations)
          
        case .walletConnectDidAppear:
          return Effect(value: .listenOnWallet)
          
        case .walletConnectDidDisappear:
          self.walletConnect.disconnect()
          return .cancel(id: WalletEventsCancellationID.self)
          
        case .didDisappear:
          return .none
          
        case .listenOnWallet:
          return .run { send in
            do {
              for try await event in self.walletConnect.eventStream {
                switch event {
                  case .didFailToConnect, .didDisconnect:
                    await send(.updateConnectionStatus(.notConnected))
                    
                  case .didConnect(_), .didUpdate(_):
                    break
                    
                  case .didEstablishSession:
                    await send(.updateConnectionStatus(.connected))
                }
              }
            } catch let error {
              log("Failed to receive wallet events", level: .warn, error: error)
            }
          }
          .cancellable(id: WalletEventsCancellationID.self)
          
        case .updateConnectionStatus(let connectionStatus):
          state.connectionStatus = connectionStatus
          return .none
          
        case .signInTapped:
          return .run { send in
            await self.xmtpConnector.createClient()
            await send(.updateConnectionStatus(.signedIn))
            await send(.loadConversations)
          }
          
        case .loadConversations:
          switch state.connectionStatus {
            case .notConnected:
              self.walletConnect.reconnect()
              return .none
              
            case .connected:
              return .none

            case .signedIn:
              return .task {
                .conversationsResult(
                  await TaskResult {
                    try await self.xmtpConnector.loadConversations()
                  }
                )
              }
          }
          
        case .conversationsResult(.success(let conversations)):
          guard case .signedIn = state.connectionStatus,
                let address = try? self.xmtpConnector.address()
          else { return .none }
          
          let conversationRows = conversations.map {
            let profile = self.cache.profileByAddress($0.peerAddress)
            return ConversationRow.State(conversation: $0, userAddress: address, profile: profile)
          }
          
          state.conversations = IdentifiedArrayOf(uniqueElements: conversationRows)
          return .none
          
        case .conversationsResult(.failure(let error)):
          log("Failed to load conversations", level: .error, error: error)
          return .none
          
        case .connectTapped:
          self.walletConnect.connect()
          return .none
          
        case .createMessageTapped:
          state.createConversation = .init()
          return .none
          
        case .setCreateConversation(let createConversationState):
          state.createConversation = createConversationState
          return .none
          
        case .createConversation(let createConversationAction):
          if case .dismiss = createConversationAction {
            state.createConversation = nil
          }
          else if case .dismissAndOpenConversation(let conversation, let userAddress) = createConversationAction {
            state.createConversation = nil
            self.navigationApi.append(
              DestinationPath(
                navigationId: self.uuid.callAsFunction().uuidString,
                destination: .conversation(conversation, userAddress)
              )
            )
          }
          return .none
          
        case .conversation:
          return .none
      }
    }
    .ifLet(\.createConversation, action: /Action.createConversation) {
      CreateConversation()
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
            .onAppear { viewStore.send(.walletConnectDidAppear) }
            
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
            conversations: [
              ConversationRow.State(
                conversation: MockData.conversations[0],
                userAddress: "0xabc123",
                profile: MockData.mockProfiles[0]
              ),
              ConversationRow.State(
                conversation: MockData.conversations[1],
                userAddress: "0xabc123"
              ),
              ConversationRow.State(
                conversation: MockData.conversations[2],
                userAddress: "0xabc123"
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
