// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
import SDWebImageSwiftUI
import SwiftUI
import XMTP


struct Conversation: ReducerProtocol {
  struct State: Equatable {
    enum From: Equatable {
      case user, peer
    }
    
    var navigationId: String
    var userAddress: String
    var conversation: XMTPConversation
    var profile: Model.Profile?
    var profilePictureURL: URL? = nil
    var messages: IdentifiedArrayOf<Message.State>
    var messageText: String = ""
    var isSending: Bool = false
    
    init(
      navigationId: String,
      userAddress: String,
      conversation: XMTPConversation,
      profile: Model.Profile? = nil,
      messages: [Message.State] = []
    ) {
      self.navigationId = navigationId
      self.userAddress = userAddress
      self.conversation = conversation
      self.profile = profile
      self.messages = IdentifiedArrayOf(uniqueElements: messages)
      self.profilePictureURL = profile?.profilePictureUrl
    }
  }
  
  enum Action: Equatable {
    case didAppear
    case didTapProfile
    case loadMessages
    case messagesResponse(TaskResult<[XMTP.DecodedMessage]>)
    case streamMessages
    case messageResponse(XMTP.DecodedMessage)
    case dismissView
    case updateMessageText(String)
    case sendMessageTapped
    case sendMessageResult
    case updateSendingStatus(Bool)
    case updateReadStatus(Message.State.ID?)
    case message(Message.State.ID, Message.Action)
  }
  
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  @Dependency(\.xmtpConnector) var xmtpConnector
  enum CancelMessageSreamID {}
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          return Effect(value: .loadMessages)
          
        case .didTapProfile:
          guard let profile = state.profile
          else { return .none }
          
          navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .profile(profile.id)
            )
          )
          return .none
          
        case .loadMessages:
          return .task { [conversation = state.conversation] in
            await .messagesResponse(
              TaskResult {
                await self.xmtpConnector.loadMessages(conversation)
              }
            )
          }
          
        case .messagesResponse(.success(let messages)):
          let calendar = Calendar.current
          var currentDate = Date(timeIntervalSince1970: 0)
          state.messages = IdentifiedArrayOf(
            uniqueElements: messages
              .sorted { lhs, rhs in
                lhs.sent < rhs.sent
              }
              .map {
                let displayDate = !calendar.isDate(currentDate, inSameDayAs: $0.sent)
                currentDate = $0.sent
                return Message.State(
                  id: self.uuid.callAsFunction().uuidString,
                  message: $0,
                  from: $0.senderAddress == state.userAddress ? .user : .peer,
                  displayDate: displayDate
                )
              }
              .sorted { lhs, rhs in
                lhs.message.sent > rhs.message.sent
              }
          )
          return .merge(
            Effect(value: .updateReadStatus(state.messages.first?.id)),
            Effect(value: .streamMessages)
          )
          
        case .streamMessages:
          return .run { [conversation = state.conversation] send in
            for try await message in conversation.streamMessages() {
              await send(.messageResponse(message))
            }
          }
          .cancellable(id: CancelMessageSreamID.self)
          
        case .messageResponse(let message):
          guard state.messages.first(where: {
            $0.message.body == message.body
            && $0.message.sent == message.sent
            && $0.message.senderAddress == message.senderAddress
          }) == nil
          else { return .none }
          
          let messageState = Message.State(
            id: self.uuid.callAsFunction().uuidString,
            message: message,
            from: message.senderAddress == state.userAddress ? .user : .peer
          )
          state.messages.insert(messageState, at: 0)
          return Effect(value: .updateReadStatus(messageState.id))
          
        case .messagesResponse(.failure(let error)):
          log("Failed to load messages", level: .error, error: error)
          return .none
          
        case .dismissView:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.navigationId,
              destination: .conversation(state.conversation, state.userAddress)
            )
          )
          return .cancel(id: CancelMessageSreamID.self)
          
        case .updateMessageText(let message):
          state.messageText = message
          return .none
          
        case .sendMessageTapped:
          guard state.messageText.trimmingCharacters(in: .whitespacesAndNewlines) != ""
          else { return .none }
          
          state.isSending = true
          return .run { [conversation = state.conversation, message = state.messageText] send in
            try await conversation.send(message)
            await send(.sendMessageResult)
            
          } catch: { error, send in
            log("Failed to send message", level: .error, error: error)
            await send(.updateSendingStatus(false))
          }
          
        case .sendMessageResult:
          state.messageText = ""
          state.isSending = false
          return Effect(value: .loadMessages)
          
        case .updateSendingStatus(let active):
          state.isSending = active
          return .none
          
        case .updateReadStatus(let id):
          guard let id,
                var latestRead = self.defaultsStorageApi.load(ConversationsLatestRead.self) as? ConversationsLatestRead,
                let messageSent = state.messages[id: id]?.message.sent
          else { return .none }
          
          do {
            latestRead.updateLatestReadMessageDate(for: state.conversation, with: messageSent)
            try self.defaultsStorageApi.store(latestRead)
          }
          catch let error {
            log("Failed to store updated last message in Defaults", level: .error, error: error)
          }
          return .none
      }
    }
  }
}

struct ConversationView: View {
  let store: Store<Conversation.State, Conversation.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack(alignment: .bottomLeading) {
        Theme.lentilGradient()
          .ignoresSafeArea()
        
        GeometryReader { geometry in
          VStack {
            Spacer()
            
            ScrollView(axes: .vertical, showsIndicators: false) {
              LazyVStack {
                ForEachStore(
                  self.store.scope(
                    state: \.messages,
                    action: Conversation.Action.message
                  ), content: { messageStore in
                    WithViewStore(messageStore, observe: { $0.from }) { messageViewStore in
                      VStack {
                        HStack {
                          if messageViewStore.state == .user { Spacer() }
                          HStack {
                            if messageViewStore.state == .user { Spacer() }
                            MessageView(store: messageStore)
                            if messageViewStore.state == .peer { Spacer() }
                          }
                          .frame(width: geometry.size.width * 0.80)
                          if messageViewStore.state == .peer { Spacer() }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .mirrored()
                        
                        MessageDateView(store: messageStore)
                          .mirrored()
                      }
                    }
                  }
                )
              }
            }
            .mirrored()
            
            VStack(spacing: 0) {
              HStack(alignment: .top) {
                TextField(
                  "Message",
                  text: viewStore.binding(
                    get: \.messageText,
                    send: Conversation.Action.updateMessageText
                  ),
                  axis: .vertical
                )
                .submitLabel(.return)
                .lineLimit(1...5)
                .padding(10)
                .background {
                  RoundedRectangle(cornerRadius: Theme.wideRadius)
                    .fill(Theme.Color.white)
                }
              
                SendButton(
                  isSending: viewStore.binding(
                    get: \.isSending,
                    send: Conversation.Action.updateSendingStatus
                  )
                ) { viewStore.send(.sendMessageTapped) }
                  .padding(.top, 5)
                .padding(.trailing, 10)
                .disabled(viewStore.messageText == "" || viewStore.isSending)
                .opacity(viewStore.messageText == "" ? 0.75 : 1.0)
              }
              .padding([.leading, .top, .bottom], 10)
            }
            .background {
              Rectangle()
                .fill(Theme.Color.greyShade1)
            }
            
            Rectangle()
              .fill(Theme.Color.greyShade1)
              .padding(.top, -10)
              .ignoresSafeArea()
              .frame(height: 0)
          }
          .task {
            await viewStore.send(.didAppear)
              .finish()
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          BackButton { viewStore.send(.dismissView) }
        }
        
        ToolbarItem(placement: .principal) {
          Text(viewStore.profile?.name ?? viewStore.profile?.handle ?? viewStore.conversation.shortenedAddress)
            .font(style: .headline, color: Theme.Color.text)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          if let url = viewStore.profilePictureURL {
            WebImage(url: url)
              .resizable()
              .placeholder {
                profileGradient(from: viewStore.profile?.handle ?? viewStore.conversation.peerAddress)
              }
              .indicator(.activity)
              .transition(.fade(duration: 0.5))
              .scaledToFill()
              .frame(width: 32, height: 32)
              .clipShape(Circle())
              .onTapGesture { viewStore.send(.didTapProfile) }
          }
          else {
            profileGradient(from: viewStore.profile?.handle ?? viewStore.conversation.peerAddress)
              .frame(width: 32, height: 32)
              .clipShape(Circle())
              .onTapGesture { viewStore.send(.didTapProfile) }
          }
        }
      }
      .toolbar(.hidden, for: .tabBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarBackground(Theme.Color.white, for: .navigationBar)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .tint(Theme.Color.primary)
    }
  }
}

#if DEBUG
struct ConversationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ConversationView(
        store: .init(
          initialState: .init(
            navigationId: "abc",
            userAddress: "0xabc123def",
            conversation: MockData.conversations[0],
            messages: [
              .init(id: "abc-123-def", message: MockData.messages[0], from: .user),
              .init(id: "abc-456-def", message: MockData.messages[1], from: .peer),
              .init(id: "abc-789-def", message: MockData.messages[2], from: .user),
              .init(id: "abc-123-ghi", message: MockData.messages[3], from: .user),
              .init(id: "abc-456-ghi", message: MockData.messages[4], from: .peer),
              .init(id: "abc-789-ghi", message: MockData.messages[5], from: .user)
            ]
          ),
          reducer: Conversation()
        )
      )
    }
  }
}

extension MockData {
  static var messages: [XMTP.DecodedMessage] {
    [
      XMTP.DecodedMessage(
        body: "Commerce on the Internet has come to rely almost exclusively on financial institutions serving as trusted third parties to process electronic payments.",
        senderAddress: "0x123456",
        sent: Date().addingTimeInterval(-60 * 60 * 24 * 5)
      ),
      XMTP.DecodedMessage(
        body: "While the system works well enough for most transactions, it still suffers from the inherent weaknesses of the trust based model. Completely non-reversible transactions are not really possible, since financial institutions cannot avoid mediating disputes. ",
        senderAddress: "0x123abcdef",
        sent: Date().addingTimeInterval(-60 * 60 * 24 * 2)
      ),
      XMTP.DecodedMessage(
        body: "The cost of mediation increases transaction costs, limiting the minimum practical transaction size and cutting off the possibility for small casual transactions, and there is a broader cost in the loss of ability to make non-reversible payments for nonreversible services.",
        senderAddress: "0xabc123",
        sent: Date().addingTimeInterval(-60 * 60 * 24)
      ),
      XMTP.DecodedMessage(
        body: "Commerce on the Internet 🥳",
        senderAddress: "0x123456",
        sent: Date().addingTimeInterval(-60 * 30)
      ),
      XMTP.DecodedMessage(
        body: "While the system works well enough 🫠",
        senderAddress: "0xabc123def",
        sent: Date().addingTimeInterval(-60 * 15)
      ),
      XMTP.DecodedMessage(
        body: "The cost of mediation 😆",
        senderAddress: "0xabc123",
        sent: Date().addingTimeInterval(-60 * 5)
      )
    ]
  }
}

#endif
