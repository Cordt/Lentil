// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
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
    var isLoading: Bool = true
    var loadingText = loadingTexts[0]
    var currentText: Int = 0
    
    var timelineState: Timeline.State
    
    var posts: IdentifiedArrayOf<Post.State> = []
    var comments: IdentifiedArrayOf<Post.State> = []
    var profiles: IdentifiedArrayOf<Profile.State> = []
    var createPublication: CreatePublication.State?
  }
  
  enum Action: Equatable {
    case loadingScreenAppeared
    case loadingScreenDisappeared
    case startTimer
    case switchProgressLabel
    
    case checkAuthenticationStatus
    case refreshTokenResponse(_ accessToken: String, QueryResult<Bool>)
    case authTokenResponse(TaskResult<MutationResult<AuthenticationTokens>>)
    
    case timelineAction(Timeline.Action)
    
    case addPath(DestinationPath)
    case removePath(DestinationPath)
    case post(id: Post.State.ID, action: Post.Action)
    case comment(id: Post.State.ID, action: Post.Action)
    case profile(id: Profile.State.ID, action: Profile.Action)
    case createPublication(CreatePublication.Action)
  }
  
  @Dependency(\.authTokenApi) var authTokenApi
  @Dependency(\.continuousClock) var clock
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.navigationApi) var navigationApi
  private enum TimerID {}

  var body: some ReducerProtocol<State, Action> {
    Scope(
      state: \State.timelineState,
      action: /Action.timelineAction
    ) {
      Timeline()
    }
    
    Reduce { state, action in
      switch action {
        case .loadingScreenAppeared:
          return .merge(
            .run { send in
              do {
                for try await event in self.navigationApi.eventStream {
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
            },
            Effect(value: .startTimer),
            Effect(value: .checkAuthenticationStatus)
          )
          
        case .loadingScreenDisappeared:
          return .cancel(id: TimerID.self)
          
        case .startTimer:
          return .run { send in
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
          
        case .checkAuthenticationStatus:
          do {
            // Verify that both access token and user are available
            if try self.authTokenApi.checkFor(.access),
               try self.authTokenApi.checkFor(.refresh),
               self.profileStorageApi.load() != nil {
              
              let accessToken = try self.authTokenApi.load(.access)
              let refreshToken = try self.authTokenApi.load(.refresh)
              
              // Verify that the access token is still valid
              return .run { send in
                try await send(.refreshTokenResponse(refreshToken, self.lensApi.verify(accessToken)))
              }
            }
            else {
              try self.authTokenApi.delete()
              self.profileStorageApi.remove()
              
              // No valid tokens or profile available, open app
              state.isLoading = false
              return .none
            }
          } catch let error {
            log("Failed to load access tokens or user profile", level: .error, error: error)
            state.isLoading = false
            return .none
          }
          
        case .refreshTokenResponse(let refreshToken, let tokenIsValid):
          if tokenIsValid.data {
            // Valid tokens and profile available, open app
            state.isLoading = false
            return .none
          }
          else {
            return .task {
              await .authTokenResponse(
                TaskResult { try await self.lensApi.refreshAuthentication(refreshToken) }
              )
            }
          }
          
        case .authTokenResponse(let .success(tokens)):
          do {
            try self.authTokenApi.store(.access, tokens.data.accessToken)
            try self.authTokenApi.store(.refresh, tokens.data.refreshToken)
            
            // Valid tokens and profile available, open app
            state.isLoading = false
            return .none
            
          } catch let error {
            log("Failed to store access tokens", level: .error, error: error)
            state.isLoading = false
            return .none
          }
          
        case .authTokenResponse(let .failure(error)):
          try? self.authTokenApi.delete()
          self.profileStorageApi.remove()
          state.isLoading = false
          
          log("Failed to refresh token, logging user out", level: .debug, error: error)
          return .none
          
        case .timelineAction:
          return .none
          
        case .addPath(let destinationPath):
          switch destinationPath.destination {
            case .publication(let elementId):
              guard let publication = publicationsCache[id: elementId]
              else { return .none }
              
              switch publication.typename {
                case .post:
                  let postState = Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication))
                  state.posts.updateOrAppend(postState)
                case .comment:
                  let commentState = Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication))
                  state.comments.updateOrAppend(commentState)
                case .mirror:
                  // Ignore for now
                  return .none
              }
              
            case .profile(let elementId):
              guard let profile = profilesCache[id: elementId]
              else { return .none }
              
              let profileState = Profile.State(navigationId: destinationPath.navigationId, profile: profile)
              state.profiles.updateOrAppend(profileState)
              
            case .createPublication(let reason):
              state.createPublication = CreatePublication.State(navigationId: destinationPath.navigationId, reason: reason)
          }
          return .none
          
        case .removePath(let destinationPath):
          switch destinationPath.destination {
            case .publication:
              state.posts.remove(id: destinationPath.navigationId)
              state.comments.remove(id: destinationPath.navigationId)
              
            case .profile:
              state.profiles.remove(id: destinationPath.navigationId)
              
            case .createPublication:
              state.createPublication = nil
          }
          return .none
          
        case .post, .comment, .profile:
          return .none
          
        case .createPublication(let createPublicationAction):
          if case .dismissView(let txHash) = createPublicationAction {
            if let txHash {
              state.timelineState.indexingPost = true
              return .task {
                do {
                  var attempts = 5
                  while attempts > 0 {
                    if let publication = try await self.lensApi.publication(txHash).data {
                      return .timelineAction(.publicationResponse(publication))
                    }
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
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
          }
          return .none

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
  }
}
