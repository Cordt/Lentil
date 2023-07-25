// Lentil

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI


struct Conversations: Reducer {
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
  enum CancelID { case walletConnectDelegate }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          if state.conversations.count == 0 {
            state.isLoading = true
          }
          return .send(.loadConversations)
          
        case .didRefresh:
          return .send(.loadConversations)
          
        case .walletConnectDidDisappear:
          self.walletConnect.disconnect()
          return .cancel(id: CancelID.walletConnectDelegate)
          
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
          .cancellable(id: CancelID.walletConnectDelegate)
          
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
            
              if state.conversations.count == 0, let conversations = try? self.xmtpConnector.loadStoredConversations() {
                let conversationRows = conversations.map {
                  ConversationRow.State(
                    conversation: $0,
                    userAddress: address
                  )
                }
                return .run { send in
                  await send(.conversationsResult(.success(conversationRows)))
                  
                  var rowsToUpdate = conversationRows
                  
                  try await fetchProfiles(updating: &rowsToUpdate)
                  await send(.conversationsResult(.success(rowsToUpdate)))
                  
                  try await fetchLastMessage(updating: &rowsToUpdate, userAddress: address)
                  await send(.conversationsResult(.success(rowsToUpdate)))
                  
                  await send(.loadConversationsFromRemote)
                }
              }
              else {
                return .send(.loadConversationsFromRemote)
              }
          }
          
        case .loadConversationsFromRemote:
          guard case .signedIn = state.connectionStatus,
                let address = try? self.xmtpConnector.address()
          else {
            state.isLoading = false
            return .none
          }
          
          return .run { [conversationRows = state.conversations] send in
            let conversations = try await self.xmtpConnector.loadConversations()
            var identifiedRowsToUpdate = conversationRows
            
            for conversation in conversations {
              if identifiedRowsToUpdate[id: conversation.topic] != nil {
                identifiedRowsToUpdate[id: conversation.topic]?.conversation = conversation
              }
              else {
                identifiedRowsToUpdate.append(
                  .init(
                    conversation: conversation,
                    userAddress: address
                  )
                )
              }
            }
            
            var rowsToUpdate = identifiedRowsToUpdate.elements
            await send(.conversationsResult(.success(rowsToUpdate)))
            
            try await fetchProfiles(updating: &rowsToUpdate)
            await send(.conversationsResult(.success(rowsToUpdate)))
            
            try await fetchLastMessage(updating: &rowsToUpdate, userAddress: address)
            await send(.conversationsResult(.success(rowsToUpdate)))
          }
          
        case .conversationsResult(.success(let conversationRows)):
          state.isLoading = false
          for row in conversationRows {
            state.conversations.updateOrAppend(row)
          }
          return .none
          
        case .conversationsResult(.failure(let error)):
          state.isLoading = false
          log("Failed to load conversations", level: .error, error: error)
          return .none
          
        case .connectTapped:
          return .merge(
            .send(.listenOnWallet),
            .run { _ in self.walletConnect.connect() }
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
              .run { [conversation = conversation, userAddress = userAddress] _ in
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
  
  func fetchLastMessage(updating rows: inout [ConversationRow.State], userAddress: String) async throws {
    for (index, row) in rows.enumerated() {
      let lastMessage = try await row.conversation.lastMessage()
      let messageStub: ConversationRow.State.Stub?
      if let lastMessage {
        messageStub = ConversationRow.State.Stub(
          message: lastMessage,
          from: lastMessage.senderAddress == userAddress ? .user : .peer
        )
      }
      else { messageStub = nil }
      rows[index].lastMessage = messageStub
    }
    
    rows.sort {
      $0.lastMessage?.sent ?? Date(timeIntervalSince1970: 0) > $1.lastMessage?.sent ?? Date(timeIntervalSince1970: 0)
    }
  }
  
  func fetchProfiles(updating rows: inout [ConversationRow.State]) async throws {
    for (index, _) in rows.enumerated() {
      let profile = try await self.cache.profileByAddress(rows[index].conversation.peerAddress)
      rows[index].profile = profile
    }
  }
}
