// Lentil

import ComposableArchitecture
import SwiftUI

struct AccountView: View {
  let store: Store<Account.State, Account.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(
          header: Text("Wallet")
            .font(.caption),
          footer: Text("Your wallet is used to sign transactions and write to Lens Protocol on Polygon. Lens Protocol uses a relayer that allows you to write gasless to the chain.")
            .font(.caption)
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
        }
        
        
        Section(
          header: Text("Authentication status")
            .font(.caption)
        ) {
          if viewStore.authenticated {
            Text("Signed in")
          } else {
            HStack(spacing: 0) {
              Text("Signed out")
              Spacer()
              SignInWithLens {
                viewStore.send(.authenticateTapped)
              }
              .buttonStyle(.plain)
              .offset(x: 12)
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
              header: Text("Unable to load profile")
                .foregroundColor(Theme.Color.systemRed)
                .font(.caption),
              footer: Text("We could not fetch the profiles for this wallet. Make sure to claim a Lens handle first.")
                .font(.caption)
            ) {
              Button("Retry") { viewStore.send(.fetchProfiles) }
              if let url = URL(string: "https:claim.lens.xyz/") {
                Link("Claim handle", destination: url)
              }
            }
          }
        )
      }
      .font(.subheadline)
      .tint(Theme.Color.primaryRed)
      .alert(self.store.scope(state: \.unlinkAlert), dismiss: .unlinkWalletCanceled)
      .signTransactionSheet(
        store: self.store.scope(
          state: \.signTransaction,
          action: Account.Action.requestSignature
        )
      )
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

