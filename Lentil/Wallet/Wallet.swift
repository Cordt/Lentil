// Lentil

import ComposableArchitecture


struct Wallet: ReducerProtocol {
  enum ConnectionState {
    case notConnected, connected, validToken
  }
  
  struct State: Equatable {
    var connectionStatus: ConnectionState = .notConnected
    var signedMessage: String?
  }
  
  enum Action: Equatable {
    case connect
    case signChallenge(String)
    case signChallengeResponse(TaskResult<String>)
  }
  
  @Dependency(\.walletConnect) var walletConnect
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .connect:
        self.walletConnect.connect()
        state.connectionStatus = .connected
        self.lensApi.authenticationChallenge
        return .none
        
      case .signChallenge(let message):
        return .task { [walletConnect = self.walletConnect] in
          await .signChallengeResponse(
            TaskResult {
              try await walletConnect.sign(message)
            }
          )
        }
        
      case .signChallengeResponse(let result):
        switch result {
          case .success(let signedMessage):
            state.signedMessage = signedMessage
            state.connectionStatus = .validToken
            
          case .failure(let error):
            print("[ERROR] Failed to sign message: \(error)")
        }
        return .none
    }
  }
}
