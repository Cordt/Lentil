// Lentil

import ComposableArchitecture
import Glaip


extension Glaip: Equatable {
  public static func == (lhs: Glaip, rhs: Glaip) -> Bool {
    return lhs.title == rhs.title && lhs.description == rhs.description
  }
}

enum WalletError: Error, Equatable {
  case connectionFailed
}

struct WalletConnect: ReducerProtocol {
  struct State: Equatable {
    var glaip: Glaip = Glaip(
      title: "Lentil App",
      description: "Lentil - Social Media via Lens Protocol",
      supportedWallets: [.MetaMask]
    )
    var walletAddress: String?
  }
  
  enum Action: Equatable {
    case connect
    case connectionResponse(Result<User, WalletError>)
    case disconnect
  }
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .connect:
        return .run { [glaip = state.glaip] send in
          let result = await withCheckedContinuation { continuation in
            glaip.loginUser(type: .MetaMask) { result in
              continuation.resume(returning: result.mapError { _ in WalletError.connectionFailed })
              
            }
          }
          await send(.connectionResponse(result))
        }
        
      case .connectionResponse(let result):
        switch result {
          case .success(let user):
            state.walletAddress = user.wallet.address
            return .none
            
          case .failure(let error):
            print("[INFO] Connection to wallet failed: \(error.localizedDescription)")
            return .none
        }
        
      case .disconnect:
        state.walletAddress = nil
        state.glaip.userState = .unregistered
        state.glaip.logout()
        return .none
    }
  }
}
