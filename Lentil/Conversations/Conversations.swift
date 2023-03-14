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
    
    var isLoading: Bool = false
  }
  
  enum Action: Equatable {
    case didAppear
    case didRefresh
    case walletConnectDidDisappear
    case didDisappear
    case listenOnWallet
    case updateConnectionStatus(State.ConnectionStatus)
    case signInTapped
    
    case loadConversations
    case loadConversationsFromRemote
    case conversationsResult(TaskResult<[ConversationRow.State]>)
    
    case connectTapped
    case createConversationTapped
    case logout
    
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
        case .didAppear:
          state.isLoading = true
          return .send(.loadConversations)
          
        case .didRefresh:
          return .send(.loadConversations)
          
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
              if self.xmtpConnector.tryLoadCLient() {
                state.connectionStatus = .signedIn
                return .send(.loadConversations)
              }
              else {
                return .none
              }
              
            case .connected:
              return .none
              
            case .signedIn:
              guard let address = try? self.xmtpConnector.address()
              else {
                state.isLoading = false
                return .none
              }
              
              if state.conversations.count == 0 {
                let conversations = try? self.xmtpConnector.loadStoredConversations().map {
                  ConversationRow.State(
                    conversation: $0,
                    userAddress: address
                  )
                }
                if let conversations, conversations.count > 0 {
                  state.isLoading = false
                  state.conversations = IdentifiedArrayOf(uniqueElements: conversations)
                }
              }
              
              return .send(.loadConversationsFromRemote)
          }
          
        case .loadConversationsFromRemote:
          guard case .signedIn = state.connectionStatus,
                let address = try? self.xmtpConnector.address()
          else {
            state.isLoading = false
            return .none
          }
          
          return .task {
            let conversations = try await self.xmtpConnector.loadConversations()
            var conversationRows: [(ConversationRow.State, Date)] = []
            for conversation in conversations {
              let profile = try await self.cache.profileByAddress(conversation.peerAddress)
              var messages = try await conversation.messages()
              messages.sort { $0.sent < $1.sent }
              
              let lastMessage: ConversationRow.State.Stub?
              let messageDate: Date
              if let message = messages.first {
                lastMessage = ConversationRow.State.Stub(
                  message: message,
                  from: message.senderAddress == address ? .user : .peer
                )
                messageDate = message.sent
              }
              else {
                lastMessage = nil
                messageDate = Date(timeIntervalSince1970: 0)
              }
              
              conversationRows.append(
                (
                  ConversationRow.State(
                    conversation: conversation,
                    userAddress: address,
                    lastMessage: lastMessage,
                    profile: profile
                  ),
                  messageDate
                )
                
              )
            }
            
            let sortedConversationRows = conversationRows
              .sorted { $0.1 > $1.1 }
              .map { $0.0 }
            
            return .conversationsResult(
              await TaskResult { [conversationRows = sortedConversationRows] in
                conversationRows
              }
            )
          }
          
        case .conversationsResult(.success(let conversationRows)):
          state.isLoading = false
          state.conversations = IdentifiedArrayOf(uniqueElements: conversationRows)
          return .none
          
        case .conversationsResult(.failure(let error)):
          state.isLoading = false
          log("Failed to load conversations", level: .error, error: error)
          return .none
          
        case .connectTapped:
          return .merge(
            .send(.listenOnWallet),
            .fireAndForget { self.walletConnect.connect() }
          )
          
        case .createConversationTapped:
          state.createConversation = .init()
          return .none
          
        case .logout:
          state.connectionStatus = .notConnected
          let conversations = state.conversations.map { $0.conversation }
          try? self.xmtpConnector.disconnect(conversations)
          return .none
          
        case .setCreateConversation(let createConversationState):
          state.createConversation = createConversationState
          return .none
          
        case .createConversation(let createConversationAction):
          if case .dismiss = createConversationAction {
            return .send(.setCreateConversation(nil))
          }
          else if case .dismissAndOpenConversation(let conversation, let userAddress) = createConversationAction {
            return .merge(
              .fireAndForget { [conversation = conversation, userAddress = userAddress] in
                try await Task.sleep(for: .seconds(1))
                self.navigationApi.append(
                  DestinationPath(
                    navigationId: self.uuid.callAsFunction().uuidString,
                    destination: .conversation(conversation, userAddress)
                  )
                )
              },
              .send(.setCreateConversation(nil))
            )
          }
          else {
            return .none
          }
          
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
