// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI
import XMTP


struct ConversationRow: Reducer {
  struct State: Equatable, Identifiable {
    struct Stub: Equatable {
      enum From { case user, peer }
      var body: String
      var sent: Date
      var from: From
      
      init(message: DecodedMessage, from: From) {
        self.body = message.bodyText
        self.sent = message.sent
        self.from = from
      }
    }
    
    var id: String { self.conversation.topic }
    
    var conversation: XMTPConversation
    var userAddress: String
    var lastMessage: Stub?
    var unreadMessages: Bool = false
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
    case loadLatestMessages
    case profilesResponse(TaskResult<PaginatedResult<[Model.Profile]>>)
    case rowTapped
    case didTapProfile
  }
  
  @Dependency(\.cacheOld) var cache
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigate) var navigate
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          var effects: [Effect<Action>] = []
          if state.profile == nil {
            effects.append(
              .run { [peerAddress = state.conversation.peerAddress] send in
                await send(.profilesResponse(
                  TaskResult { try await self.lensApi.profiles(peerAddress) }
                ))
              }
            )
          }
          effects.append(.send(.loadLatestMessages))
          return .merge(effects)
          
        case .loadLatestMessages:
          do {
            let latestRead: ConversationsLatestRead
            if let latestReadFromDefaults = self.defaultsStorageApi.load(ConversationsLatestRead.self) as? ConversationsLatestRead {
              latestRead = latestReadFromDefaults
            }
            else {
              latestRead = ConversationsLatestRead(latestReadMessages: [])
              try self.defaultsStorageApi.store(latestRead)
            }
            
            if let lastMessage = state.lastMessage,
               let latestReadDate = latestRead.latestReadMessageDate(from: state.conversation),
               lastMessage.sent > latestReadDate {
              state.unreadMessages = true
            }
            else {
              state.unreadMessages = false
            }
          }
          catch let error {
            log("Failed to store Latest Messages to defaults", level: .error, error: error)
          }
          return .none
          
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
          self.navigate.navigate(.conversation(state.conversation, state.userAddress))
          return .none
          
        case .didTapProfile:
          guard let profile = state.profile
          else { return .none }
          
          self.navigate.navigate(.profile(profile.id))
          return .none
      }
    }
  }
}
