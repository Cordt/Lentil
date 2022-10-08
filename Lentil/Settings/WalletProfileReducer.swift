// Lentil

import ComposableArchitecture


struct WalletProfileState: Equatable, Identifiable {
  var profile: Profile
  var id: String { self.profile.id }
}

enum WalletProfileAction: Equatable {
  case defaultProfileToggled(_ active: Bool)
}

let walletProfileReducer = Reducer<WalletProfileState, WalletProfileAction, Void> { state, action, _ in
  switch action {
    case .defaultProfileToggled:
      return .none
  }
}
