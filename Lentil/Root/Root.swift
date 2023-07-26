// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI


struct Root: Reducer {
  static let loadingTexts = [
    "plowing beds",
    "planting seeds",
    "tending to seedlings",
    "spreading some fertiliser",
    "letting the sun in",
    "hunting bugs",
    "loving thy garden 🌱"
  ]
  
  struct LensPath: Reducer {
    enum State: Equatable {
      case publication(Post.State)
      case profile(Profile.State)
      case showNotifications(Notifications.State)
      case createPublication(CreatePublication.State)
    }
    
    enum Action: Equatable {
      case publication(Post.Action)
      case profile(Profile.Action)
      case showNotifications(Notifications.Action)
      case createPublication(CreatePublication.Action)
    }
    
    var body: some Reducer<State, Action> {
      Scope(state: /State.publication, action: /Action.publication) {
        Post()
      }
      Scope(state: /State.profile, action: /Action.profile) {
        Profile()
      }
      Scope(state: /State.showNotifications, action: /Action.showNotifications) {
        Notifications()
      }
      Scope(state: /State.createPublication, action: /Action.createPublication) {
        CreatePublication()
      }
    }
  }
  
  struct XMTPPath: Reducer {
    enum State: Equatable {
      case conversation(Conversation.State)
    }
    
    enum Action: Equatable {
      case conversation(Conversation.Action)
    }
    
    var body: some Reducer<State, Action> {
      Scope(state: /State.conversation, action: /Action.conversation) {
        Conversation()
      }
    }
  }
  
  struct State: Equatable {
    enum TabDestination: Equatable {
      case feed, messages
    }
    
    var lensPath = StackState<LensPath.State>()
    var xmtpPath = StackState<XMTPPath.State>()
    
    var isLoading: Bool = true
    var loadingText = loadingTexts[0]
    var currentText: Int = 0
    
    var tabDestination: TabDestination = .feed
    var timelineState: Timeline.State = .init()
    var conversationsState: Conversations.State = .init()
  }
  
  enum Action: Equatable {
    enum Destination: Equatable {
      case publication(_ elementId: String)
      case profile(_ elementId: String)
      case showNotifications
      case createPublication(_ reason: CreatePublication.State.Reason)
      case imageDetail(_ imageUrl: URL)
      
      case conversation(_ conversation: XMTPConversation, _ userAddress: String)
    }
    
    case lensPath(StackAction<LensPath.State, LensPath.Action>)
    case xmtpPath(StackAction<XMTPPath.State, XMTPPath.Action>)
    case navigate(to: Destination)
    case appendToLensStack(destination: LensPath.State)
    case appendToXMTPStack(destination: XMTPPath.State)
    
    case rootAppeared
    case rootDisappeared
    
    case loadingScreenAppeared
    case hideLoadingScreen
    case loadingScreenDisappeared
    case startTimer
    case switchProgressLabel
    
    case checkAuthenticationStatus
    case refreshTokenResponse(Bool)
    
    case timelineAction(Timeline.Action)
    case conversationsAction(Conversations.Action)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.continuousClock) var clock
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.keychainApi) var keychainApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigate) var navigate
  @Dependency(\.withRandomNumberGenerator) var randomNumberGenerator
  
  private enum CancelID {
    case timer
    case navigationEvents
  }
  
  var body: some Reducer<State, Action> {
    Scope(state: \State.timelineState, action: /Action.timelineAction) {
      Timeline()
    }
    
    Scope(state: \State.conversationsState, action: /Action.conversationsAction) {
      Conversations()
    }
    
    Reduce { state, action in
      switch action {
        case .lensPath(let stackAction):
          switch stackAction {
            case .element(id: _, action: _):
              return .none
            case .popFrom(id: _):
              return .none
              
            case .push(id: _, state: _):
              return .none
          }
          
        case .xmtpPath(let stackAction):
          switch stackAction {
            case .element(id: _, action: _):
              return .none
            case .popFrom(id: _):
              return .none
              
            case .push(id: _, state: _):
              return .none
          }
          
        case .navigate(let destination):
          return self.fetch(destination)
          
        case .appendToLensStack(destination: let path):
          state.lensPath.append(path)
          return .none
          
        case .appendToXMTPStack(destination: let path):
          state.xmtpPath.append(path)
          return .none
        
        case .rootAppeared:
          return .run { send in
            do {
              for try await event in self.navigate.eventStream() {
                switch event {
                  case .navigate(let destination):
                    await send(.navigate(to: destination))
                }
              }
            } catch let error {
              log("Failed to receive navigation events", level: .error, error: error)
            }
          }
          .cancellable(id: CancelID.navigationEvents, cancelInFlight: true)
          
        case .rootDisappeared:
          return .cancel(id: CancelID.navigationEvents)
          
        case .loadingScreenAppeared:
          state.currentText = Int(self.randomNumberGenerator.callAsFunction {
            $0.next(upperBound: UInt8(state.loadingText.count) - 1)
          })
          return .merge(
            .send(.startTimer),
            .send(.checkAuthenticationStatus)
          )
          
        case .hideLoadingScreen:
          state.isLoading = false
          return .none
          
        case .loadingScreenDisappeared:
          return .cancel(id: CancelID.timer)
          
        case .startTimer:
          return .run { [isLoading = state.isLoading] send in
            guard isLoading else { return }
            for await _ in self.clock.timer(interval: .seconds(1.5)) {
              await send(.switchProgressLabel, animation: .default)
            }
          }
          .cancellable(id: CancelID.timer, cancelInFlight: true)
          
        case .switchProgressLabel:
          let itemNumber = (state.currentText + 1) % Root.loadingTexts.count
          state.currentText += 1
          state.loadingText = Root.loadingTexts[itemNumber]
          return .none
          
        case .checkAuthenticationStatus:
          do {
            // Verify that both access token and user are available
            if self.keychainApi.hasStored(AccessToken.access.key),
               self.keychainApi.hasStored(AccessToken.refresh.key),
               self.defaultsStorageApi.load(UserProfile.self) != nil {
              
              // Verify that the access token is still valid
              return .run { send in
                let valid = try await self.lensApi.verify()
                await send(.refreshTokenResponse(valid))
              }
            }
            else {
              try self.keychainApi.delete(AccessToken.access.key)
              try self.keychainApi.delete(AccessToken.refresh.key)
              self.defaultsStorageApi.remove(UserProfile.self)
              
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
              try? self.keychainApi.delete(AccessToken.access.key)
              try? self.keychainApi.delete(AccessToken.refresh.key)
              self.defaultsStorageApi.remove(UserProfile.self)
              log("Failed to refresh token, logging user out", level: .debug, error: error)
              try? await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
            }
          }
          
        case .timelineAction:
          return .none
          
        case .conversationsAction:
          return .none
      }
    }
    .forEach(\.lensPath, action: /Action.lensPath) {
      LensPath()
    }
    .forEach(\.xmtpPath, action: /Action.xmtpPath) {
      XMTPPath()
    }
  }
  
  func fetchIndexedTransaction(txHash: String?, state: inout State) -> Effect<Action> {
    if let txHash {
      state.timelineState.isIndexing = Toast(message: "Indexing publication", duration: .long)
      return .run { send in
        do {
          var attempts = 5
          while attempts > 0 {
            if let publication = try await self.lensApi.publicationByHash(txHash) {
              await send(.timelineAction(.publicationResponse(publication)))
              return
            }
            try await self.clock.sleep(for: .seconds(5))
            attempts -= 1
          }
          log("Failed to load recently created publication for TX Hash after 5 retries \(txHash)", level: .warn)
          await send(.timelineAction(.publicationResponse(nil)))
          return
          
        } catch let error {
          log("Failed to load recently created publication for TX Hash \(txHash)", level: .error, error: error)
          await send(.timelineAction(.publicationResponse(nil)))
          return
        }
      }
    }
    else {
      return .none
    }
  }
  
  func fetch(_ destination: Root.Action.Destination) -> Effect<Action> {
    switch destination {
      case .publication(let elementId):
        return .run { send in
          guard let publication = try await self.cache.publication(elementId)
          else { return }
          
          await send(
            .appendToLensStack(
              destination: .publication(
                Post.State(
                  navigationId: UUID().uuidString,
                  post: Publication.State(publication: publication),
                  typename: Post.State.Typename.from(typename: publication.typename)
                )
              )
            )
          )
        }
        
      case .profile(let elementId):
        return .run { send in
          guard let profile = try await self.cache.profile(elementId)
          else { return }
          
          await send(
            .appendToLensStack(
              destination: .profile(
                Profile.State(
                  navigationId: UUID().uuidString,
                  profile: profile
                )
              )
            )
          )
        }
        
      case .showNotifications:
        return .run { send in
          await send(
            .appendToLensStack(
              destination: .showNotifications(
                Notifications.State(navigationId: UUID().uuidString)
              )
            )
          )
        }
        
      case .createPublication(let reason):
        return .run { send in
          await send(
            .appendToLensStack(
              destination: .createPublication(
                CreatePublication.State(navigationId: UUID().uuidString, reason: reason)
              )
            )
          )
        }
        
      case .conversation(let conversation, let userAddress):
        return .run { send in
          await send(
            .appendToXMTPStack(
              destination: .conversation(
                Conversation.State(
                  navigationId: UUID().uuidString,
                  userAddress: userAddress,
                  conversation: conversation
                )
              )
            )
          )
        }
        
      case .imageDetail(let url):
        return .run { send in
          // TODO: Add Image Detail
        }
    }
  }
}
