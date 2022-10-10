// Lentil

import ComposableArchitecture
import SwiftUI


struct SettingsView: View {
  let store: Store<SettingsState, SettingsAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      IfLetStore(
        self.store.scope(
          state: \.walletState,
          action: SettingsAction.wallet
        )
      ) { WalletView(store: $0) }
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
          send: SettingsAction.setLinkWallet(isPresented:)
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
                  send: SettingsAction.privateKeyTextChanged(text:)
                )
              )
              SecureField(
                "Enter a password to protect it",
                text: viewStore.binding(
                  get: \.passwordTextField,
                  send: SettingsAction.passwordTextChanged(text:)
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
          send: SettingsAction.setLoadWallet(isPresented:)
        ),
        content: {
          Form {
            Section(header: Text("Load your Ethereum wallet")) {
              SecureField(
                "Enter your password",
                text: viewStore.binding(
                  get: \.loadWalletPasswordTextField,
                  send: SettingsAction.loadWalletPasswordTextChanged(text:)
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
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      SettingsView(
        store: Store(
          initialState: .init(),
          reducer: settingsReducer,
          environment: .mock
        )
      )
      
      SettingsView(
        store: .init(
          initialState: .init(
            walletState: WalletState(
              wallet: testWallet,
              walletProfilesState: WalletProfilesState(wallet: testWallet, profiles: [.init(wallet: testWallet, profile: mockProfiles[2])])
            )
          ),
          reducer: settingsReducer,
          environment: .mock
        )
      )
    }
  }
}