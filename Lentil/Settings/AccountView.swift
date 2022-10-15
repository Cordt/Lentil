// Lentil

import ComposableArchitecture
import SwiftUI

struct AccountView: View {
  let store: Store<Account.State, Account.Action>
  
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
              .tint(Theme.Color.systemRed)
          }
          HStack {
            Text("Address: \(viewStore.addressShort)")
            Spacer()
            Button("Copy") {  }
              .buttonStyle(.borderless)
          }
          HStack {
            if viewStore.authenticated {
              Text("Authenticated")
            }
            else {
              Text("Not authenticated")
              Spacer()
              Button("Sign in", action: { viewStore.send(.authenticateTapped) })
                .buttonStyle(.borderless)
            }
          }
        }
        
        IfLetStore(
          self.store.scope(
            state: \.walletProfilesState,
            action: Account.Action.walletProfilesAction
          ),
          then: WalletProfilesView.init,
          else: {
            Section(
              header: Text("Unable to load profile").foregroundColor(Theme.Color.systemRed),
              footer: Text("We could not fetch the profiles for this wallet. Make sure to claim a Lens handle first.")
            ) {
              Button("Retry") { viewStore.send(.fetchProfiles) }
              if let url = URL(string: "https://claim.lens.xyz/") {
                Link("Claim handle", destination: url)
              }
            }
          }
        )
        
      }
      .alert(self.store.scope(state: \.unlinkAlert), dismiss: .unlinkWalletCanceled)
      .tint(Theme.Color.primaryRed)
    }
  }
}

struct WalletView_Previews: PreviewProvider {
  static var previews: some View {
    AccountView(
      store: .init(
        initialState: .init(
          walletProfilesState: WalletProfiles.State(
            profiles: [.init(profile: mockProfiles[2])]
          )
        ),
        reducer: Account()
      )
    )
  }
}
