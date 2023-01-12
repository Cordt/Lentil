// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SDWebImageSwiftUI
import SwiftUI
import XMTP


struct ConversationRow: ReducerProtocol {
  struct State: Equatable, Identifiable {
    struct Stub: Equatable {
      enum From { case user, peer }
      var body: String
      var sent: String
      var from: From
      
      init(message: DecodedMessage, from: From) {
        self.body = message.body
        self.sent = age(message.sent)
        self.from = from
      }
    }
    
    var id: String { self.conversation.topic }
    
    var conversation: XMTPConversation
    var userAddress: String
    var lastMessage: Stub?
    var profile: Model.Profile?
    var profilePictureURL: URL?
    
    init(
      conversation: XMTPConversation,
      userAddress: String,
      lastMessage: Stub? = nil,
      profile: Model.Profile? = nil
    ) {
      self.conversation = conversation
      self.userAddress = userAddress
      self.lastMessage = lastMessage
      self.profile = profile
      self.profilePictureURL = profile?.profilePictureUrl
    }
  }
  
  enum Action: Equatable {
    case didAppear
    case profilesResponse(TaskResult<PaginatedResult<[Model.Profile]>>)
    case rowTapped
    case didTapProfile
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          if state.profile == nil {
            return .task { [peerAddress = state.conversation.peerAddress] in
              await .profilesResponse(
                TaskResult {
                  try await self.lensApi.profiles(peerAddress)
                }
              )
            }
          }
          else { return .none }
          
        case .profilesResponse(.success(let result)):
          guard let profile = result.data.first
          else { return .none }
          
          self.cache.updateOrAppendProfile(profile)
          state.profile = profile
          return .none
          
        case .profilesResponse(.failure(let error)):
          log("Failed to fetch profiles for conversations list", level: .error, error: error)
          return .none
          
        case .rowTapped:
          navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .conversation(state.conversation, state.userAddress)
            )
          )
          return .none
          
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
      }
    }
  }
}

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
              
              Text(lastMessage.sent)
                .font(style: .annotation, color: Theme.Color.greyShade3)
            }
          }
          
          if let lastMessage = viewStore.lastMessage {
            switch lastMessage.from {
              case .user:
                VStack(alignment: .leading) {
                  Text("You:")
                    .font(style: .annotation)
                  Text(lastMessage.body)
                    .font(style: .annotation, color: Theme.Color.greyShade3)
                }
              case .peer:
                Text(lastMessage.body)
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
          reducer: ConversationRow()
        )
      )
      ConversationRowView(
        store: .init(
          initialState: .init(
            conversation: MockData.conversations[1],
            userAddress: "0xabc123",
            profile: MockData.mockProfiles[1]
          ),
          reducer: ConversationRow()
        )
      )
      ConversationRowView(
        store: .init(
          initialState: .init(
            conversation: MockData.conversations[2],
            userAddress: "0xabc123",
            lastMessage: .init(message: MockData.messages[2], from: .peer)
          ),
          reducer: ConversationRow()
        )
      )
    }
    .padding()
  }
}
#endif
