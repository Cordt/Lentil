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
    case walletClosed
    case updateConnectionState(ConnectionState)
    case errorMessageUpdated(Toast?)
    case connectTapped
    case signInTapped
    case authenticationResponse
    case defaultProfileLoaded(Model.Profile)
  }
  
  @Dependency(\.walletConnect) var walletConnect
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
      case .walletClosed:
        return .run { _ in
          try await self.walletConnect.disconnect()
        }
        
      case .updateConnectionState(let connectionState):
        if case let .connected(address) = connectionState {
          state.address = address
        }
        state.connectionStatus = connectionState
        return .none
        
      case .errorMessageUpdated(let toast):
        state.errorMessage = toast
        return .none
        
      case .connectTapped:
        return .merge(
          .send(.updateConnectionState(.waitingForConnection)),
          .run { send in
            let address = try await self.walletConnect.connect()
            await send(.updateConnectionState(.connected(address)))
          }
          catch: { error, send in
            if case WalletConnector.CommunicationError.invalidWalletAddress = error {
              log("Failed to get address for WC session", level: .error)
              await send(.errorMessageUpdated(Toast(message: "We couldn't get your wallet's address :( Please try again")))
              await send(.updateConnectionState(.notConnected))
            }
            else if case WalletConnector.CommunicationError.invalidWalletResponse = error {
              log("Failed to handle response from signature", level: .warn, error: error)
              await send(.errorMessageUpdated(Toast(message: "We couldn't establish a connection with your wallet :( Please try again")))
              await send(.updateConnectionState(.notConnected))
            }
          }
        )
        
      case .signInTapped:
        guard let address = state.address else {
          log("Failed to get address for WC session", level: .error)
          return .merge(
            .send(.errorMessageUpdated(Toast(message: "We couldn't get your wallet's address :( Please try again"))),
            .send(.updateConnectionState(.notConnected))
          )
        }
        return .merge(
          .send(.updateConnectionState(.waitingForSignature)),
          .run { send in
            let challenge = try await self.lensApi.authenticationChallenge(address)
            let signature = try await self.walletConnect.personalSign(challenge.message)
            try await self.lensApi.authenticate(address, signature)
            log("Successfully authenticated user with challenge", level: .info)
            await send(.authenticationResponse)
          }
          catch: { error, send in
            if case WalletConnector.CommunicationError.invalidSession = error {
              log("Failed to connect to WC session", level: .warn, error: error)
              await send(.errorMessageUpdated(Toast(message: "We couldn't connect you to your wallet :( Please try again")))
              await send(.updateConnectionState(.notConnected))
            }
            else if case WalletConnector.CommunicationError.invalidWalletResponse = error {
              log("Failed to handle response from signature", level: .warn, error: error)
              await send(.errorMessageUpdated(Toast(message: "We couldn't retrieve the signature from your wallet :( Please try again")))
              await send(.updateConnectionState(.connected(address)))
            }
            else {
              log("Failed to create challenge or authenticate user on lens", level: .warn, error: error)
              await send(.errorMessageUpdated(Toast(message: "We couldn't authenticate you on lens :( Please try again")))
              await send(.updateConnectionState(.connected(address)))
            }
          }
        )
        
      case .authenticationResponse:
        log("Trying to fetch default profile", level: .info)
        guard let address = state.address else { return .none }
        
        return .run { send in
          let defaultProfile = try await lensApi.defaultProfile(address)
          let userProfile = UserProfile(id: defaultProfile.id, handle: defaultProfile.handle, name: defaultProfile.name, address: address)
          try self.defaultsStorageApi.store(userProfile)
          
          await send(.defaultProfileLoaded(defaultProfile))
          await send(.updateConnectionState(.authenticated))
        }
        catch: { error, send in
          log("Failed to load or store default profile for user", level: .error, error: error)
          await send(.errorMessageUpdated(Toast(message: "Your default profile could not be loaded. Did you claim your Lens Handle with this wallet?")))
          await send(.updateConnectionState(.authenticated))
        }
        
      case .defaultProfileLoaded:
        return .none
    }
  }
}
