// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Foundation


struct WalletConnection: Reducer {
  enum ConnectionState: Equatable {
    case notConnected
    case waitingForConnection
    case connected(_ address: String)
    case waitingForSignature
    case authenticated
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
    case signatureResponse(String)
    case authenticationResponse
    case failedToLoadAuthTokens
    case defaultProfileResponse(Model.Profile)
    case failedToLoadDefaultProfile
    case errorMessageUpdated(Toast?)
  }
  
  @Dependency(\.walletConnect) var walletConnect
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  enum CancelID { case walletEvents }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
      case .walletOpened:
        return .run { send in
          do {
            for try await event in self.walletConnect.eventStream {
              switch event {
                case .didEstablishSession(let session):
                  guard let address = session.accounts.first?.address
                  else { log("Could not get wallet address from session", level: .error); break }
                  await send(.updateConnectionState(.connected(address)))
                  
                case .receivedResponse(let response):
                  await send(.signatureResponse(response))
                  
                case .didDisconnect:
                  await send(.updateConnectionState(.notConnected))
              }
            }
          } catch let error {
            log("Failed to receive wallet events", level: .warn, error: error)
          }
        }
        .cancellable(id: CancelID.walletEvents)
        
      case .walletClosed:
        self.walletConnect.disconnect()
        return .cancel(id: CancelID.walletEvents)
        
      case .updateConnectionState(let connectionState):
        if case let .connected(address) = connectionState {
          state.address = address
        }
        state.connectionStatus = connectionState
        return .none
        
      case .connectTapped:
        self.walletConnect.connect()
        return .send(.updateConnectionState(.waitingForConnection))
        
      case .signInTapped:
        guard let address = state.address else { return .none }
        return .merge(
          .send(.updateConnectionState(.waitingForSignature)),
          .run { send in
            await send(
              .challengeResponse(
                TaskResult {
                  try await lensApi.authenticationChallenge(address)
                }
              )
            )
          }
        )
          
      case let .challengeResponse(.success(challenge)):
        log("Trying to sign challenge", level: .info)
        return .run { [walletConnect = self.walletConnect] send in
          try await walletConnect.signMessage(challenge.message)

        } catch: { error, send in
          await send(.failedToLoadAuthTokens)
          log("Failed to authenticate user", level: .info, error: error)
        }
        
      case .signatureResponse(let signature):
        guard let address = state.address else { return .none }
        
        return .run { send in
          try await lensApi.authenticate(address, signature)
          log("Successfully authenticated user with challenge", level: .info)
          await send(.authenticationResponse)
          
        } catch: { error, send in
          await send(.failedToLoadAuthTokens)
          log("Failed to authenticate user", level: .info, error: error)
        }
        
      case .failedToLoadAuthTokens:
        log("Could not retrieve tokens for signature", level: .error)
        state.errorMessage = Toast(message: "We couldn't authenticate you :( Please try again")
        return .none
        
      case let .challengeResponse(.failure(error)):
        log("Could not retrieve challenge to sign", level: .error, error: error)
        return .none
        
      case .authenticationResponse:
        log("Trying to fetch default profile", level: .info)
        guard let address = state.address else { return .none }
        
        return .run { send in
          let defaultProfile = try await lensApi.defaultProfile(address)
          await send(.defaultProfileResponse(defaultProfile))
          
        } catch: { error, send in
          await send(.failedToLoadDefaultProfile)
          log("Failed to load default profile for user", level: .info, error: error)
        }
      
      case .defaultProfileResponse(let defaultProfile):
        do {
          guard let address = state.address else { return .none }
          let userProfile = UserProfile(id: defaultProfile.id, handle: defaultProfile.handle, name: defaultProfile.name, address: address)
          try self.defaultsStorageApi.store(userProfile)
          
          state.connectionStatus = .authenticated
          
        } catch let error {
          log("Failed to store user profile to defaults", level: .error, error: error)
          state.errorMessage = Toast(message: "Default Profile could not be loaded. Did you claim your Lens Handle with this wallet?")
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
