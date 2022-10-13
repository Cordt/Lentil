// Lentil

import ComposableArchitecture
import SwiftUI

struct WalletProfilesView: View {
  let store: Store<WalletProfiles.State, WalletProfiles.Action>
  
  var body: some View {
    ForEachStore(
      self.store.scope(
        state: \.profiles,
        action: WalletProfiles.Action.profileAction
      )
    ) { profileStore in
      WalletProfileView(store: profileStore)
    }
    .confirmationDialog(
      self.store.scope(
        state: \.setDefaultProfileConfirmationDialogue),
      dismiss: .cancelSetDefaultProfile
    )
  }
}

struct WalletProfilesView_Previews: PreviewProvider {
  @Dependency(\.walletApi) static var walletApi
  
  static var previews: some View {
    Form {
      WalletProfilesView(
        store: .init(
          initialState: .init(
            wallet: try! walletApi.getWallet(),
            profiles: [
              .init(wallet: try! walletApi.getWallet(), profile: mockProfiles[2]),
              .init(wallet: try! walletApi.getWallet(), profile: mockProfiles[3], isLast: true)
            ]
          ),
          reducer: WalletProfiles()
        )
      )
    }
  }
}
