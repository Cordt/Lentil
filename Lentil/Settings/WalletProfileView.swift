// Lentil

import ComposableArchitecture
import SwiftUI


struct WalletProfileView: View {
  let store: Store<WalletProfile.State, WalletProfile.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      if viewStore.isLast {
        Section(
          header: Text("Profile \(viewStore.profile.id)"),
          footer: Text("Your wallet can hold any number of profile NFTs. The default profile is the one that will be used for interacting with Lens Protocol.")
        ) {
          self.content
        }
        .tint(ThemeColor.primaryRed.color)
        .signTransactionSheet(
          store: self.store.scope(
            state: \WalletProfile.State.signTransaction,
            action: WalletProfile.Action.requestSignature
          )
        )
      }
      else {
        Section(header: Text("Profile \(viewStore.profile.id)")) {
          self.content
        }
        .tint(ThemeColor.primaryRed.color)
        .signTransactionSheet(
          store: self.store.scope(
            state: \WalletProfile.State.signTransaction,
            action: WalletProfile.Action.requestSignature
          )
        )
      }
    }
  }
  
  var content: some View {
    WithViewStore(self.store) { viewStore in
      if let profileName = viewStore.profile.name {
        HStack {
          Text("Name: \(profileName)")
          Spacer()
          Button("Edit") { }
        }
      }
      else {
        HStack {
          Text("Profile name not set")
            .italic()
          Spacer()
          Button("Set") { }
            .buttonStyle(.borderless)
        }
      }
      
      Text("Handle: \(viewStore.profile.handle)")
      Toggle(
        "Default Profile",
        isOn: viewStore.binding(
          get: \.profile.isDefault,
          send: WalletProfile.Action.defaultProfileToggled
        )
      )
    }
  }
}


struct WalletProfileView_Previews: PreviewProvider {
  @Dependency(\.walletApi) static var walletApi
  
  static var previews: some View {
    Form {
      WalletProfileView(
        store: .init(
          initialState: .init(wallet: try! walletApi.getWallet(), profile: mockProfiles[2], isLast: true),
          reducer: WalletProfile()
        )
      )
    }
  }
}
