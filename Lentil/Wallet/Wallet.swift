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
    
    var errorMessage: Toast? = nil
  }
  
  enum Action: Equatable {
    case walletOpened
    case walletClosed
    case updateConnectionState(ConnectionState)
    case connectTapped
    case signInTapped
    case challengeResponse(TaskResult<Challenge>)
    case authenticationChallengeResponse(TaskResult<AuthenticationTokens>)
    case defaultProfileResponse(Model.Profile)
    case failedToLoadDefaultProfile
    case errorMessageUpdated(Toast?)
  }
  
  @Dependency(\.walletConnect) var walletConnect
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.authTokenApi) var authTokenApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  enum WalletEventsCancellationID {}
  
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
                    log("Could not get wallet address from session", level: .error)
                    break
                  }
                  await send(.updateConnectionState(.connected(address)))
              }
            }
          } catch let error {
            log("Failed to receive wallet events", level: .warn, error: error)
          }
        }
        .cancellable(id: WalletEventsCancellationID.self)
        
      case .walletClosed:
        self.walletConnect.disconnect()
        return .cancel(id: WalletEventsCancellationID.self)
        
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
        log("Trying to sign challenge", level: .info)
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
        log("Could not retrieve challenge to sign", level: .error, error: error)
        return .none
        
      case .authenticationChallengeResponse(.success(let tokens)):
        log("Successfully retrieved tokens", level: .info)
        do {
          try authTokenApi.store(.access, tokens.accessToken)
          try authTokenApi.store(.refresh, tokens.refreshToken)
        } catch let error {
          log("Could not store auth tokens", level: .error, error: error)
        }
        
        state.connectionStatus = .authenticated
        
        guard let address = state.address else { return .none }
        return .run { send in
          do {
            let defaultProfile = try await lensApi.defaultProfile(address).data
            await send(.defaultProfileResponse(defaultProfile))
          } catch let error {
            try authTokenApi.delete()
            await send(.failedToLoadDefaultProfile)
            log("Could not retrieve profile for user", level: .info, error: error)
          }
        }
        
      case .authenticationChallengeResponse(.failure(let error)):
        log("Could not retrieve tokens for signature", level: .error, error: error)
        state.errorMessage = Toast(message: "We couldn't authenticate you :( Please try again")
        return .none
        
        
      case .defaultProfileResponse(let defaultProfile):
        do {
          guard let address = state.address else { return .none }
          let userProfile = UserProfile(id: defaultProfile.id, handle: defaultProfile.handle, name: defaultProfile.name, address: address)
          try self.profileStorageApi.store(userProfile)
        } catch let error {
          log("Failed to store user profile to defaults", level: .error, error: error)
        }
        return .none
        
      case .failedToLoadDefaultProfile:
        state.errorMessage = Toast(message: "Default Profile could not be loaded. Did you claim your Lens Handle with this wallet?")
        return .none
        
      case .errorMessageUpdated(let toast):
        state.errorMessage = toast
        return .none
    }
  }
}
