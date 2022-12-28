// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI
import XMTP


struct ConversationRow: ReducerProtocol {
  struct MessageStub: Equatable {
    var stub: String
    var lastMessage: Date
    var from: Lentil.Conversation.State.From
  }
  
  struct State: Equatable, Identifiable {
    var id: String { self.conversation.peerAddress }
    var conversation: XMTPConversation
    
    var profile: Model.Profile?
    var profilePicture: LentilImage.State?
    var lastMessage: MessageStub?
    
    init(conversation: XMTPConversation, profile: Model.Profile? = nil, lastMessage: MessageStub? = nil) {
      self.conversation = conversation
      self.profile = profile
      self.profilePicture = nil
      self.lastMessage = lastMessage
      
      if let profilePictureUrl = profile?.profilePictureUrl {
        self.profilePicture = .init(
          imageUrl: profilePictureUrl,
          kind: .profile(profile?.handle ?? conversation.peerAddress)
        )
      }
    }
  }
  
  enum Action: Equatable {
    case rowTapped
    case profilePicture(LentilImage.Action)
  }
  
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .rowTapped:
          navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .conversation(state.conversation)
            )
          )
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

struct ConversationRowView: View {
  let store: Store<ConversationRow.State, ConversationRow.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HStack {
        IfLetStore(
          self.store.scope(
            state: \.profilePicture,
            action: ConversationRow.Action.profilePicture
          ),
          then: {
            LentilImageView(store: $0)
              .frame(width: 40, height: 40)
              .clipShape(Circle())
          },
          else: {
            profileGradient(from: viewStore.profile?.handle ?? viewStore.conversation.peerAddress)
              .frame(width: 40, height: 40)
              .clipShape(Circle())
          }
        )
        
        VStack(alignment: .leading) {
          HStack {
            if let profile = viewStore.profile {
              if let name = profile.name {
                Text(name)
                  .font(style: .bodyBold)
              }
              Text("@\(profile.handle)")
                .font(style: .body)
            }
            else {
              Text(viewStore.conversation.peerAddress)
                .font(style: .bodyBold)
            }
            
            if let lastMessage = viewStore.lastMessage {
              Spacer()
              
              Text(age(lastMessage.lastMessage))
                .font(style: .annotation, color: Theme.Color.greyShade3)
            }
          }
          
          if let lastMessage = viewStore.lastMessage {
            switch lastMessage.from {
              case .user:
                VStack(alignment: .leading) {
                  Text("You:")
                    .font(style: .annotation)
                  Text(lastMessage.stub)
                    .font(style: .annotation, color: Theme.Color.greyShade3)
                }
              case .peer:
                Text(lastMessage.stub)
                  .font(style: .annotation, color: Theme.Color.greyShade3)
            }
          }
          else {
            Text("No messages in this conversation yet")
              .font(style: .annotation, color: Theme.Color.greyShade3)
              .italic()
          }
        }
        .frame(height: 50)
        
        Spacer()
      }
      .onTapGesture { viewStore.send(.rowTapped) }
    }
  }
}

#if DEBUG
struct ConversationRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ConversationRowView(
        store: .init(
          initialState: .init(
            conversation: MockData.conversations[0],
            profile: MockData.mockProfiles[0],
            lastMessage: MockData.conversationStubs[0]
          ),
          reducer: ConversationRow()
        )
      )
      ConversationRowView(
        store: .init(
          initialState: .init(
            conversation: MockData.conversations[1],
            profile: MockData.mockProfiles[1]
          ),
          reducer: ConversationRow()
        )
      )
      ConversationRowView(
        store: .init(
          initialState: .init(
            conversation: MockData.conversations[2],
            lastMessage: MockData.conversationStubs[2]
          ),
          reducer: ConversationRow()
        )
      )
    }
    .padding()
  }
}
#endif
