// Lentil

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
    case conversationsResult(TaskResult<[ConversationRow.State]>)
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
              guard case .signedIn = state.connectionStatus,
                    let address = try? self.xmtpConnector.address()
              else { return .none }
              
              return .task {
                let conversations = try await self.xmtpConnector.loadConversations()
                var conversationRows: [ConversationRow.State] = []
                for conversation in conversations {
                  let profile = self.cache.profileByAddress(conversation.peerAddress)
                  var messages = try await conversation.messages()
                  messages.sort { $0.sent < $1.sent }

                  let lastMessage: ConversationRow.State.Stub?
                  if let message = messages.first {
                    lastMessage = ConversationRow.State.Stub(
                      message: message,
                      from: message.senderAddress == address ? .user : .peer
                    )
                  }
                  else {
                    lastMessage = nil
                  }

                  conversationRows.append(
                    ConversationRow.State(
                      conversation: conversation,
                      userAddress: address,
                      lastMessage: lastMessage,
                      profile: profile
                    )
                  )
                }
                
                return .conversationsResult(
                  await TaskResult { [conversationRows = conversationRows] in
                    conversationRows
                  }
                )
              }
          }
          
        case .conversationsResult(.success(let conversationRows)):
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
