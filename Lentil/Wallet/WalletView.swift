// Lentil

import ComposableArchitecture
import SwiftUI


struct WalletView: View {
  let store: Store<Wallet.State, Wallet.Action>
  
  func step(state: Wallet.ConnectionState) -> String {
    switch state {
      case .notConnected: return "1/3"
      case .connected:    return "2/3"
      case .validToken:   return "3/3"
    }
  }
  
  func title(state: Wallet.ConnectionState) -> String {
    switch state {
      case .notConnected: return "Connect your Wallet"
      case .connected:    return "Sign in"
      case .validToken:   return "Success!"
    }
  }
  
  func body(state: Wallet.ConnectionState) -> String {
    switch state {
      case .notConnected: return "You need to connect your wallet and Lens handle to Lentil in order to interact with content on Lentil.\n\nDon't have access to Lens yet? Reach out to them to get yourself a Lens handle!"
      case .connected:    return "Sign in with Lens to interact with content on Lentil.\n\nDon’t have access to Lens yet? Reach out to them to get yourself a Lens handle!"
      case .validToken:   return "You are now logged in and can start interacting.\n\nHave fun!"
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        Rectangle()
          .fill(lentilGradient())
          .ignoresSafeArea()
        
        VStack(spacing: 20) {
          Text(step(state: viewStore.connectionStatus))
            .font(style: .bodyDetailed, color: Theme.Color.white)
          
          VStack(spacing: 20) {
            Text(title(state: viewStore.connectionStatus))
              .font(style: .largeHeadline)
            
            Text(body(state: viewStore.connectionStatus))
              .font(style: .bodyDetailed)
          }
          .multilineTextAlignment(.center)
          .padding(30)
          .background {
            RoundedRectangle(cornerRadius: 5)
              .fill(Theme.Color.white)
          }
          .padding([.leading, .trailing], 30)
          
          switch viewStore.connectionStatus {
            case .notConnected:
              LentilButton(title: "Connect now") {
                viewStore.send(.connect)
              }
              
            case .connected:
              LentilButton(title: "Sign in with Lens", kind: .primary) {
                viewStore.send(.signChallenge("Sign this message!"))
              }
              
            case .validToken:
              Text(viewStore.signedMessage ?? "")
              LentilButton(title: "Let's go!", kind: .primary) {
                
              }
          }
        }
      }
    }
  }
}


struct WalletConnectView_Previews: PreviewProvider {
  static var previews: some View {
    WalletView(
      store: .init(
        initialState: Wallet.State(connectionStatus: .validToken),
        reducer: Wallet()
      )
    )
  }
}
