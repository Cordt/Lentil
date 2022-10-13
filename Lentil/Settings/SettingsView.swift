// Lentil

import ComposableArchitecture
import SwiftUI


struct SettingsView: View {
  let store: Store<Settings.State, Settings.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      IfLetStore(
        self.store.scope(
          state: \.accountState,
          action: Settings.Action.accountAction
        )
      ) { AccountView(store: $0) }
      else: {
          Form {
            Section(
              header: Text("Wallet"),
              footer: Text("Your wallet is used to sign transactions and write to Lens Protocol on Polygon. You can use Lentil without a wallet, but it will be read-only.")
            ) {
              HStack {
                Text("No wallet linked")
                Spacer()
                Button("Link", action: { viewStore.send(.linkWalletTapped) })
                  .buttonStyle(.borderless)
              }
            }
          }
        }
      .tint(ThemeColor.primaryRed.color)
      .sheet(
        isPresented: viewStore.binding(
          get: \.isLinkWalletPresented,
          send: Settings.Action.setLinkWallet(isPresented:)
        ),
        content: {
          Form {
            Section(
              header: Text("Link your Ethereum wallet"),
              footer: Text("Your private key is stored in your iPhone's keychain and encrypted using the password you specify. It is not synced via iCloud or otherwise.")
            ) {
              SecureField(
                "Enter your private key",
                text: viewStore.binding(
                  get: \.privateKeyTextField,
                  send: Settings.Action.privateKeyTextChanged(text:)
                )
              )
              SecureField(
                "Enter a password to protect it",
                text: viewStore.binding(
                  get: \.passwordTextField,
                  send: Settings.Action.passwordTextChanged(text:)
                )
              )
            }
            Section {
              Button("Cancel", role: .destructive) {
                viewStore.send(.setLinkWallet(isPresented: false))
              }
              Button("Confirm") {
                viewStore.send(.linkWallet)
              }
            }
          }
          .tint(ThemeColor.primaryRed.color)
        }
      )
      .sheet(
        isPresented: viewStore.binding(
          get: \.isLoadWalletPresented,
          send: Settings.Action.setLoadWallet(isPresented:)
        ),
        content: {
          Form {
            Section(header: Text("Load your Ethereum wallet")) {
              SecureField(
                "Enter your password",
                text: viewStore.binding(
                  get: \.loadWalletPasswordTextField,
                  send: Settings.Action.loadWalletPasswordTextChanged(text:)
                )
              )
            }
            Section {
              Button("Cancel", role: .destructive) {
                viewStore.send(.setLoadWallet(isPresented: false))
              }
              Button("Confirm") {
                viewStore.send(.loadWallet)
              }
            }
          }
          .tint(ThemeColor.primaryRed.color)
        }
      )
      .onAppear {
        viewStore.send(.didAppear)
      }
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SettingsView(
        store: Store(
          initialState: .init(),
          reducer: Settings()
        )
      )
      
      SettingsView(
        store: .init(
          initialState: .init(
            accountState: Account.State(
              walletProfilesState: WalletProfiles.State(profiles: [.init(profile: mockProfiles[2])])
            )
          ),
          reducer: Settings()
        )
      )
    }
  }
}
