// Lentil

import ComposableArchitecture
import SwiftUI
import WalletConnectUtils


struct Settings: ReducerProtocol {
  struct State: Equatable {
    var walletUri: WalletConnectURI?
  }
  
  enum Action: Equatable {
    case didAppear
    case openWallet
    case failedToConnect
    case didConnect(WalletConnectURI)
    case didDisconnect
  }
  
  @Dependency(\.walletConnect) var walletConnect
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .didAppear:
        walletConnect.connect()
        return .run { [walletConnect] send in
          let uri = try await walletConnect.selectChain()
          await send(.didConnect(uri))
        }
        
//        return .run { [walletConnect] send in
//          for await _ in walletConnectFactory.failedToConnect(proxy: walletConnect) {
//            await send(.failedToConnect)
//          }
//          for await walletInfo in walletConnectFactory.didConnect(proxy: walletConnect) {
//            await send(.didConnect(walletInfo))
//          }
//          for await _ in walletConnectFactory.didDisconnect(proxy: walletConnect) {
//            await send(.didDisconnect)
//          }
//        }
        
      case .openWallet:
        guard let uri = state.walletUri
        else { return .none }
        walletConnect.openWallet(uri: uri)
        return .none
        
      case .failedToConnect:
        print("Failed to connect")
        return .none
        
      case .didConnect(let uri):
        print("Did connect with uri: \(uri)")
        state.walletUri = uri
        return .none
        
      case .didDisconnect:
        print("Did disconnect")
        return .none
    }
  }
}
