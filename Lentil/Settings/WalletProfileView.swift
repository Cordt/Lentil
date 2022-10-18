// Lentil

import ComposableArchitecture
import SwiftUI


struct WalletProfileView: View {
  let store: Store<WalletProfile.State, WalletProfile.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      if viewStore.isLast {
        Section(
          header: Text("Profile \(viewStore.profile.id)")
            .font(.caption),
          footer: Text("Your wallet can hold any number of profile NFTs. The default profile is the one that will be used for interacting with Lens Protocol.")
            .font(.caption)
        ) {
          self.content
        }
        .tint(Theme.Color.primaryRed)
        .signTransactionSheet(
          store: self.store.scope(
            state: \WalletProfile.State.signTransaction,
            action: WalletProfile.Action.requestSignature
          )
        )
      }
      else {
        Section(
          header: Text("Profile \(viewStore.profile.id)")
            .font(.caption)
        ) {
          self.content
        }
        .tint(Theme.Color.primaryRed)
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
        .font(.subheadline)
      }
      else {
        HStack {
          Text("Profile name not set")
            .italic()
          Spacer()
          Button("Set") { }
            .buttonStyle(.borderless)
        }
        .font(.subheadline)
      }
      
      Text("Handle: \(viewStore.profile.handle)")
        .font(.subheadline)
      Toggle(
        "Default Profile",
        isOn: viewStore.binding(
          get: \.profile.isDefault,
          send: WalletProfile.Action.defaultProfileToggled
        )
      )
      .font(.subheadline)
    }
  }
}


struct WalletProfileView_Previews: PreviewProvider {
  static var previews: some View {
    Form {
      WalletProfileView(
        store: .init(
          initialState: .init(profile: mockProfiles[2], isLast: true),
          reducer: WalletProfile()
        )
      )
    }
  }
}
