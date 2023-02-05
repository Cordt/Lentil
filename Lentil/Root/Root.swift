// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI


struct Root: ReducerProtocol {
  static let loadingTexts = [
    "plowing beds",
    "planting seeds",
    "tending to seedlings",
    "spreading some fertiliser",
    "letting the sun in",
    "hunting bugs",
    "loving thy garden 🌱"
  ]
  
  struct State: Equatable {
    enum TabDestination: Equatable {
      case feed, messages
    }
    var isLoading: Bool = true
    var loadingText = loadingTexts[0]
    var currentText: Int = 0
    
    var tabDestination: TabDestination = .feed
    var timelineState: Timeline.State = .init()
    var conversationsState: Conversations.State = .init()
    
    var posts: IdentifiedArray = IdentifiedArrayOf(id: \Post.State.navigationId)
    var comments: IdentifiedArray = IdentifiedArrayOf(id: \Post.State.navigationId)
    var profiles: IdentifiedArray = IdentifiedArrayOf(id: \Profile.State.navigationId)
//    var showNotifications: Notifications.State?
    var createPublication: CreatePublication.State?
    var imageDetail: URL?
    var conversation: Conversation.State?
  }
  
  enum Action: Equatable {
    case loadingScreenAppeared
    case hideLoadingScreen
    case loadingScreenDisappeared
    case startTimer
    case switchProgressLabel
    case dismissImageDetail(DestinationPath)
    
    case checkAuthenticationStatus
    case refreshTokenResponse(Bool)
    
    case rootAppeared
    case rootDisappeared
    
    case timelineAction(Timeline.Action)
    case conversationsAction(Conversations.Action)
    
    case addPath(DestinationPath)
    case removePath(DestinationPath)
    case post(id: Post.State.ID, action: Post.Action)
    case comment(id: Post.State.ID, action: Post.Action)
    case profile(id: Profile.State.ID, action: Profile.Action)
//    case showNotifications(Notifications.Action)
    case createPublication(CreatePublication.Action)
    case conversation(Conversation.Action)
  }
  
  @Dependency(\.keychainApi) var keychainApi
  @Dependency(\.cache) var cache
  @Dependency(\.continuousClock) var clock
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.withRandomNumberGenerator) var randomNumberGenerator
  private enum TimerID {}
  private enum NavigationEventsID {}
  
  func fetchIndexedTransaction(txHash: String?, state: inout State) -> EffectTask<Action> {
    if let txHash {
      state.timelineState.isIndexing = Toast(message: "Indexing publication", duration: .long)
      return .task {
        do {
          var attempts = 5
          while attempts > 0 {
            if let publication = try await self.lensApi.publication(txHash) {
              return .timelineAction(.publicationResponse(publication))
            }
            try await self.clock.sleep(for: .seconds(5))
            attempts -= 1
          }
          log("Failed to load recently created publication for TX Hash after 5 retries \(txHash)", level: .warn)
          return .timelineAction(.publicationResponse(nil))
          
        } catch let error {
          log("Failed to load recently created publication for TX Hash \(txHash)", level: .error, error: error)
          return .timelineAction(.publicationResponse(nil))
        }
      }
    }
    else {
      return .none
    }
  }
  
  func handleAddPath(state: inout State, _ destinationPath: DestinationPath) -> EffectTask<Action> {
    switch destinationPath.destination {
      case .publication(let elementId):
        guard let publication = self.cache.publication(elementId)
        else { return .none }
        
        switch publication.typename {
          case .post:
            state.posts.updateOrAppend(
              Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication), typename: .post)
            )
          case .comment:
            state.comments.updateOrAppend(
              Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication), typename: .comment)
            )
          case .mirror:
            state.posts.updateOrAppend(
              Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication), typename: .mirror)
            )
            return .none
        }
        
      case .profile(let elementId):
        guard let profile = self.cache.profileById(elementId)
        else { return .none }
        state.profiles.updateOrAppend(
          Profile.State(navigationId: destinationPath.navigationId, profile: profile)
        )
        
//      case .showNotifications:
//        state.showNotifications = Notifications.State()
        
      case .createPublication(let reason):
        state.createPublication = CreatePublication.State(navigationId: destinationPath.navigationId, reason: reason)
        
      case .conversation(let conversation, let userAddress):
        state.conversation = Conversation.State(
          navigationId: destinationPath.navigationId,
          userAddress: userAddress,
          conversation: conversation,
          profile: self.cache.profileByAddress(conversation.peerAddress)
        )
      
      case .imageDetail(let url):
        state.imageDetail = url
    }
    return .none
  }
  
  func handleRemovePath(state: inout State, _ destinationPath: DestinationPath) -> EffectTask<Action> {
    switch destinationPath.destination {
      case .publication:
        state.posts.remove(id: destinationPath.id)
        state.comments.remove(id: destinationPath.id)
        
      case .profile:
        state.profiles.remove(id: destinationPath.id)
        
//      case .showNotifications:
//        state.showNotifications = nil
        
      case .createPublication:
        state.createPublication = nil
        
      case .imageDetail:
        state.imageDetail = nil
        
      case .conversation:
        state.conversation = nil
    }
    return .none
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \State.timelineState, action: /Action.timelineAction) {
      Timeline()
    }
    
    Scope(state: \State.conversationsState, action: /Action.conversationsAction) {
      Conversations()
    }
    
    Reduce { state, action in
      switch action {
        case .loadingScreenAppeared:
          state.currentText = Int(self.randomNumberGenerator.callAsFunction {
            $0.next(upperBound: UInt8(state.loadingText.count) - 1)
          })
          return .merge(
            EffectTask(value: .startTimer),
            EffectTask(value: .checkAuthenticationStatus)
          )
          
        case .hideLoadingScreen:
          state.isLoading = false
          return .none
          
        case .loadingScreenDisappeared:
          return .cancel(id: TimerID.self)
          
        case .startTimer:
          return .run { [isLoading = state.isLoading] send in
            guard isLoading else { return }
            for await _ in self.clock.timer(interval: .seconds(1.5)) {
              await send(.switchProgressLabel, animation: .default)
            }
          }
          .cancellable(id: TimerID.self, cancelInFlight: true)
          
        case .switchProgressLabel:
          let itemNumber = (state.currentText + 1) % Root.loadingTexts.count
          state.currentText += 1
          state.loadingText = Root.loadingTexts[itemNumber]
          return .none
          
        case .dismissImageDetail(let destinationPath):
          self.navigationApi.remove(destinationPath)
          return .none
          
        case .checkAuthenticationStatus:
          do {
            // Verify that both access token and user are available
            if self.keychainApi.checkFor(AccessToken.access),
               self.keychainApi.checkFor(AccessToken.refresh),
               self.defaultsStorageApi.load(UserProfile.self) != nil {
              
              // Verify that the access token is still valid
              return .run { send in
                let valid = try await self.lensApi.verify()
                await send(.refreshTokenResponse(valid))
              }
            }
            else {
              try self.keychainApi.delete(AccessToken.access)
              try self.keychainApi.delete(AccessToken.refresh)
              self.defaultsStorageApi.remove(UserProfile.self)
              self.cache.clearCache()
              
              // No valid tokens or profile available, open app
              return .run { send in
                try await self.clock.sleep(for: .seconds(1))
                await send(.hideLoadingScreen)
              }
            }
          } catch let error {
            log("Failed to load access tokens or user profile", level: .error, error: error)
            return .run { send in
              try await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
            }
          }
          
        case .refreshTokenResponse(let tokenIsValid):
          if tokenIsValid {
            // Valid tokens and profile available, open app
            return .run { send in
              try await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
            }
          }
          else {
            return .run { send in
              try await self.lensApi.refreshAuthentication()
              try await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
              
            } catch: { error, send in
              try? self.keychainApi.delete(AccessToken.access)
              try? self.keychainApi.delete(AccessToken.refresh)
              self.defaultsStorageApi.remove(UserProfile.self)
              self.cache.clearCache()
              log("Failed to refresh token, logging user out", level: .debug, error: error)
              try? await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
            }
          }
          
        case .rootAppeared:
          return .run { send in
            do {
              for try await event in self.navigationApi.eventStream() {
                switch event {
                  case .append(let destinationPath):
                    await send(.addPath(destinationPath))
                  case .remove(let destinationPath):
                    await send(.removePath(destinationPath))
                }
              }
            } catch let error {
              log("Failed to receive navigation events", level: .error, error: error)
            }
          }
          .cancellable(id: NavigationEventsID.self, cancelInFlight: true)
          
        case .rootDisappeared:
          return .cancel(id: NavigationEventsID.self)
          
        case .timelineAction(let timelineAction):
          if case .post(_, let postAction) = timelineAction {
            if case .post(.mirrorSuccess(let txHash)) = postAction {
              return fetchIndexedTransaction(txHash: txHash, state: &state)
            }
            else {
              return .none
            }
          }
          else {
            return .none
          }
          
        case .conversationsAction:
          return .none
          
        case .addPath(let destinationPath):
          return self.handleAddPath(state: &state, destinationPath)
          
        case .removePath(let destinationPath):
          return self.handleRemovePath(state: &state, destinationPath)
          
        case .post, .comment, .profile, .conversation:
          return .none
          
        case .createPublication(let createPublicationAction):
          if case .dismissView(let txHash) = createPublicationAction {
            return fetchIndexedTransaction(txHash: txHash, state: &state)
          }
          else {
            return .none
          }
      }
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
    .forEach(\.comments, action: /Action.comment) {
      Post()
    }
    .forEach(\.profiles, action: /Action.profile) {
      Profile()
    }
    .ifLet(\.createPublication, action: /Action.createPublication) {
      CreatePublication()
    }
    .ifLet(\.conversation, action: /Action.conversation) {
      Conversation()
    }
  }
}
