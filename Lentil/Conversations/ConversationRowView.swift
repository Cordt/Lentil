// Lentil

import ComposableArchitecture
import SDWebImageSwiftUI
import SwiftUI


struct ConversationRowView: View {
  let store: StoreOf<ConversationRow>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HStack {
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
        
        VStack(alignment: .leading, spacing: 0) {
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
              
              Text(age(lastMessage.sent))
                .font(style: .annotation, color: Theme.Color.greyShade3)
            }
          }
          
          if let lastMessage = viewStore.lastMessage {
            HStack {
              switch lastMessage.from {
                case .user:
                  VStack(alignment: .leading) {
                    Text("You:")
                      .font(style: .annotation)
                    Text(lastMessage.body)
                      .font(style: .annotation, color: Theme.Color.greyShade3)
                      .bold(viewStore.unreadMessages)
                  }
                case .peer:
                  Text(lastMessage.body)
                    .font(style: .annotation, color: Theme.Color.greyShade3)
                    .bold(viewStore.unreadMessages)
              }
              
              if viewStore.unreadMessages {
                Circle()
                  .fill(Theme.Color.secondary)
                  .frame(width: 15, height: 15)
              }
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
      .onAppear { viewStore.send(.didAppear) }
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
            userAddress: "0xabc123",
            lastMessage: .init(message: MockData.messages[0], from: .user),
            profile: MockData.mockProfiles[0]
          ),
          reducer: { ConversationRow() }
        )
      )
      ConversationRowView(
        store: .init(
          initialState: .init(
            conversation: MockData.conversations[1],
            userAddress: "0xabc123",
            profile: MockData.mockProfiles[1]
          ),
          reducer: { ConversationRow() }
        )
      )
      ConversationRowView(
        store: .init(
          initialState: .init(
            conversation: MockData.conversations[2],
            userAddress: "0xabc123",
            lastMessage: .init(message: MockData.messages[2], from: .peer)
          ),
          reducer: { ConversationRow() }
        )
      )
    }
    .padding()
  }
}
#endif

