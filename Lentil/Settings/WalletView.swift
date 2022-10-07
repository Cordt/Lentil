// Lentil

import ComposableArchitecture
import SwiftUI

struct WalletView: View {
  let store: Store<WalletState, WalletAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(
          header: Text("Wallet"),
          footer: Text("Your wallet is used to sign transactions and write to Lens Protocol on Polygon. Lens Protocol uses a relayer that allows you to write gasless to the chain.")
        ) {
          HStack {
            Text("Status: Linked")
            Spacer()
            Button("Unlink") { viewStore.send(.unlinkWalletTapped) }
              .buttonStyle(.borderless)
              .tint(ThemeColor.systemRed.color)
          }
          HStack {
            Text("Address: \(viewStore.publicAddressShort)")
            Spacer()
            Button("Copy") {  }
              .buttonStyle(.borderless)
          }
        }
        
        IfLetStore(
          self.store.scope(
            state: \.settingsProfileState,
            action: WalletAction.settingsProfileAction
          ),
          then: SettingsProfileView.init,
          else: {
            Section(
              header: Text("Unable to load profile").foregroundColor(ThemeColor.systemRed.color),
              footer: Text("We could not fetch the default profile for this wallet. Make sure to claim a Lens handle first.")
            ) {
              Button("Retry") { viewStore.send(.fetchDefaultProfile) }
              if let url = URL(string: "https://claim.lens.xyz/") {
                Link("Claim handle", destination: url)
              }
            }
          }
        )
        
      }
      .alert(self.store.scope(state: \.unlinkAlert), dismiss: .unlinkWalletCanceled)
      .tint(ThemeColor.primaryRed.color)      
    }
  }
}

struct WalletView_Previews: PreviewProvider {
  static var previews: some View {
    WalletView(
      store: .init(
        initialState: .init(
          wallet: testWallet,
          settingsProfileState: .init(profile: mockProfiles[2])
        ),
        reducer: walletReducer,
        environment: .mock
      )
    )
  }
}
