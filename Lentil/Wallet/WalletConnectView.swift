// Lentil

import ComposableArchitecture
import SwiftUI


struct WalletConnectView: View {
  let store: Store<WalletConnect.State, WalletConnect.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        Rectangle()
          .fill(lentilGradient())
          .ignoresSafeArea()
        
        VStack(spacing: 20) {
          Text("1/3")
            .font(style: .bodyDetailed, color: Theme.Color.white)
          
          VStack(spacing: 20) {
            Text("Connect your Wallet")
              .font(style: .largeHeadline)
            
            Text("You need to connect your wallet and Lens handle to Lentil in order to interact with content on Lentil.")
              .font(style: .bodyDetailed)
            
            Text("Don't have access to Lens yet? Reach out to them to get yourself a Lens handle!")
              .font(style: .bodyDetailed)
          }
          .multilineTextAlignment(.center)
          .padding(30)
          .background {
            RoundedRectangle(cornerRadius: 5)
              .fill(Theme.Color.white)
          }
          .padding([.leading, .trailing], 30)
          
          if let address = viewStore.walletAddress {
            Text(address)
              .font(.title)
            LentilButton(title: "Disconnect", kind: .secondary) {
              viewStore.send(.disconnect)
            }
          }
          else {
            LentilButton(title: "Connect now") {
              viewStore.send(.connect)
            }
          }
        }
      }
    }
  }
}


struct WalletConnectView_Previews: PreviewProvider {
  static var previews: some View {
    WalletConnectView(
      store: .init(
        initialState: .init(),
        reducer: WalletConnect()
      )
    )
  }
}
