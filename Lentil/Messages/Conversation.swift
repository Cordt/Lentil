// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
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
    var profilePicture: LentilImage.State? = nil
    var messages: IdentifiedArrayOf<Message.State>
    var message: String = ""
    
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
      
      if let profilePictureUrl = profile?.profilePictureUrl {
        self.profilePicture = .init(
          imageUrl: profilePictureUrl,
          kind: .profile(profile?.handle ?? conversation.peerAddress)
        )
      }
    }
  }
  
  enum Action: Equatable {
    case didAppear
    case loadMessages
    case messagesResponse(TaskResult<[XMTP.DecodedMessage]>)
    case dismissView
    case updateMessageText(String)
    case sendMessageTapped
    case profilePicture(LentilImage.Action)
    case message(Message.State.ID, Message.Action)
  }
  
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  @Dependency(\.xmtpConnector) var xmtpConnector
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          return Effect(value: .loadMessages)
          
        case .loadMessages:
          return .task { [conversation = state.conversation] in
            await .messagesResponse(
              TaskResult {
                await self.xmtpConnector.loadMessages(conversation)
              }
            )
          }
          
        case .messagesResponse(.success(let messages)):
          state.messages = IdentifiedArrayOf(
            uniqueElements: messages.map {
              Message.State(
                id: self.uuid.callAsFunction().uuidString,
                message: $0,
                from: $0.senderAddress == state.userAddress ? .user : .peer
              )
            }
          )
          return .none
          
        case .messagesResponse(.failure):
          return .none
          
        case .dismissView:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.navigationId,
              destination: .conversation(state.conversation)
            )
          )
          return .none
          
        case .updateMessageText(let message):
          state.message = message
          return .none
          
        case .sendMessageTapped:
          state.message = ""
          return .none
          
        case .profilePicture:
          return .none
      }
    }
    .ifLet(\.profilePicture, action: /Action.profilePicture) {
      LentilImage()
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
            ScrollView(axes: .vertical, showsIndicators: false) {
              LazyVStack {
                ForEachStore(
                  self.store.scope(
                    state: \.messages,
                    action: Conversation.Action.message
                  ), content: { messageStore in
                    WithViewStore(messageStore, observe: { $0.from }) { messageViewStore in
                      HStack {
                        if messageViewStore.state == .peer { Spacer() }
                        
                        HStack {
                          if messageViewStore.state == .peer { Spacer() }
                          MessageView(store: messageStore)
                          if messageViewStore.state == .user { Spacer() }
                        }
                        .frame(width: geometry.size.width * 0.80)
                        
                        if messageViewStore.state == .user { Spacer() }
                      }
                      .padding(.horizontal)
                      .padding(.vertical, 5)
                    }
                  }
                )
              }
            }
            
            Spacer()
            
            VStack {
              HStack {
                TextField(
                  "Message",
                  text: viewStore.binding(
                    get: \.message,
                    send: Conversation.Action.updateMessageText
                  )
                )
                .padding(10)
                .background {
                  RoundedRectangle(cornerRadius: Theme.wideRadius)
                    .fill(Theme.Color.white)
                }
                .padding([.leading, .top, .bottom], 10)
              
                SendButton { viewStore.send(.sendMessageTapped) }
                .padding(.trailing, 10)
                .disabled(viewStore.message == "")
                .opacity(viewStore.message == "" ? 0.75 : 1.0)
              }
              
              Spacer()
            }
            .background {
              Rectangle()
                .fill(Theme.Color.greyShade1)
            }
            .ignoresSafeArea()
            .frame(height: 70)
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
          IfLetStore(
            self.store.scope(
              state: \.profilePicture,
              action: Conversation.Action.profilePicture
            ),
            then: {
              LentilImageView(store: $0)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            },
            else: {
              profileGradient(from: viewStore.profile?.handle ?? viewStore.conversation.peerAddress)
                .frame(width: 32, height: 32)
            }
          )
        }
      }
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarBackground(Theme.Color.white, for: .navigationBar)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .tint(Theme.Color.white)
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
              .init(id: "abc-789-def", message: MockData.messages[2], from: .user)
            ]
          ),
          reducer: Conversation()
        )
      )
    }
  }
}

extension MockData {
  static var conversationStubs: [ConversationRow.MessageStub] {
    [
      ConversationRow.MessageStub(
        stub: "Hello, I hope this finds you well. I have a sample text for you that goes like this: Lorem ipsum dolor",
        lastMessage: Date().addingTimeInterval(-60 * 5),
        from: .peer
      ),
      ConversationRow.MessageStub(
        stub: "Hello, I hope this finds you well. I have a sample text for you that goes like this: Lorem ipsum dolor",
        lastMessage: Date().addingTimeInterval(-60 * 60 * 5),
        from: .user
      ),
      ConversationRow.MessageStub(
        stub: "Hello, I hope this finds you well. I have a sample text for you that goes like this: Lorem ipsum dolor",
        lastMessage: Date().addingTimeInterval(-60 * 60 * 24),
        from: .user
      ),
    ]
  }
  
  static var messages: [XMTP.DecodedMessage] {
    [
      XMTP.DecodedMessage(
        body: "Hello, I hope this finds you well. I have a sample text for you that goes like this: Lorem ipsum dolor",
        senderAddress: "0x123456",
        sent: Date().addingTimeInterval(-60 * 5)
      ),
      XMTP.DecodedMessage(
        body: "Hello, I hope this finds you well. I have a sample text for you that goes like this: Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec?",
        senderAddress: "0xabc123def",
        sent: Date().addingTimeInterval(-60 * 60)
      ),
      XMTP.DecodedMessage(
        body: "Hello!",
        senderAddress: "0xabc123",
        sent: Date().addingTimeInterval(-60 * 60 * 5)
      )
    ]
  }
}

#endif
