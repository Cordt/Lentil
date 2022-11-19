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
  }
  
  @Dependency(\.authTokenApi) var authTokenApi
  @Dependency(\.continuousClock) var clock
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
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
                TaskResult {
                  try await self.lensApi.refreshAuthentication(refreshToken)
                }
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
      }
    }
  }
}
