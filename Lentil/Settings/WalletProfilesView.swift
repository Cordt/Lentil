// Lentil

import ComposableArchitecture
import SwiftUI

struct WalletProfilesView: View {
  let store: Store<WalletProfilesState, WalletProfilesAction>
  
  var body: some View {
    ForEachStore(
      self.store.scope(
        state: \.profiles,
        action: WalletProfilesAction.profileAction
      )
    ) { profileStore in
      WalletProfileView(store: profileStore)
    }
  }
}

struct WalletProfilesView_Previews: PreviewProvider {
  static var previews: some View {
    Form {
      WalletProfilesView(
        store: .init(
          initialState: .init(
            profiles: [.init(profile: mockProfiles[2]), .init(profile: mockProfiles[3])]
          ),
          reducer: walletProfilesReducer,
          environment: .mock
        )
      )
    }
  }
}
