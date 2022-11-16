// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Foundation


struct Wallet: ReducerProtocol {
  enum ConnectionState: Equatable {
    case notConnected, connected(_ address: String), authenticated
  }
  
  struct State: Equatable {
    var connectionStatus: ConnectionState = .notConnected
    var address: String?
  }
  
  enum Action: Equatable {
    case walletOpened
    case walletClosed
    case updateConnectionState(ConnectionState)
    case connectTapped
    case signInTapped
    case challengeResponse(TaskResult<Challenge>)
    case authenticationChallengeResponse(TaskResult<AuthenticationTokens>)
  }
  
  @Dependency(\.walletConnect) var walletConnect
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.authTokenApi) var authTokenApi
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .walletOpened:
        return .run { send in
          do {
            for try await event in self.walletConnect.eventStream {
              switch event {
                case .didFailToConnect, .didDisconnect:
                  await send(.updateConnectionState(.notConnected))
                  
                case .didConnect(_), .didUpdate(_):
                  break
                  
                case .didEstablishSession(let session):
                  guard let address = session.walletInfo?.accounts.first
                  else {
                    print("[ERROR] Could not get wallet address from session")
                    break
                  }
                  await send(.updateConnectionState(.connected(address)))
              }
            }
          } catch let error {
            print("Failed to receive wallet events: \(error)")
          }
        }
        
      case .walletClosed:
        self.walletConnect.disconnect()
        return .none
        
      case .updateConnectionState(let connectionState):
        if case let .connected(address) = connectionState {
          state.address = address
        }
        state.connectionStatus = connectionState
        return .none
        
      case .connectTapped:
        self.walletConnect.connect()
        return .none
        
      case .signInTapped:
        guard let address = state.address else { return .none }
        return .task {
          await .challengeResponse(
            TaskResult {
              try await lensApi.authenticationChallenge(address).data
            }
          )
        }
        
      case let .challengeResponse(.success(challenge)):
        print("[INFO] Trying to sign challenge: \(challenge)")
        guard let address = state.address else { return .none }
        
        return .task { [walletConnect = self.walletConnect] in
          if try authTokenApi.checkFor(.access) { try authTokenApi.delete() }
          let signature = try await walletConnect.sign(challenge.message)
          return await .authenticationChallengeResponse(
            TaskResult {
              try await lensApi.authenticate(address, signature).data
            }
          )
        }
        
      case let .challengeResponse(.failure(error)):
        print("[ERROR] Could not retrieve challenge to sign: \(error)")
        return .none
        
      case .authenticationChallengeResponse(.success(let tokens)):
        if ProcessInfo.processInfo.environment["LOG_LEVEL"]! == "INFO" {
          print("[INFO] Successfully retrieved tokens: \(tokens)")
        }
        do {
          try authTokenApi.store(.access, tokens.accessToken)
          try authTokenApi.store(.refresh, tokens.refreshToken)
        } catch let error {
          print("[ERROR] Could not store auth tokens: \(error)")
        }
        
        state.connectionStatus = .authenticated
        return .none
        
      case .authenticationChallengeResponse(.failure(let error)):
        print("[ERROR] Could not retrieve tokens for signature: \(error)")
        return .none
    }
  }
}
