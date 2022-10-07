// Lentil

import ComposableArchitecture

struct WalletState: Equatable {
  var wallet: Wallet
  var unlinkAlert: AlertState<WalletAction>?
  
  var publicAddressShort: String {
    self.wallet.address.prefix(4)
    + "..." +
    self.wallet.address.suffix(4)
  }
  
  var settingsProfileState: SettingsProfileState?
}

enum WalletAction: Equatable {
  case fetchDefaultProfile
  case defaultProfileResponse(TaskResult<Profile>)
  
  case unlinkWalletTapped
  case unlinkWalletConfirmed
  case unlinkWalletCanceled
  
  case settingsProfileAction(SettingsProfileAction)
}

let walletReducer: Reducer<WalletState, WalletAction, SettingsEnvironment> = Reducer { state, action, env in
  switch action {
    case .fetchDefaultProfile:
      return .task { [address = state.wallet.address] in
        await .defaultProfileResponse(
          TaskResult {
            try await env.lensApi.defaultProfile(address).data
          }
        )
      }
      
    case .defaultProfileResponse(.success(let profile)):
      state.settingsProfileState = .init(profile: profile)
      return .none
      
    case .defaultProfileResponse(.failure(let error)):
      print("[WARN] Could not fetch default profile from API: \(error)")
      return .none
      
    case .unlinkWalletTapped:
      state.unlinkAlert = AlertState(
        title: TextState("Do you really want to unlink your wallet?"),
        buttons: [.destructive(TextState("Unlink"), action: .send(.unlinkWalletConfirmed))]
      )
      return .none
      
    case .unlinkWalletConfirmed, .unlinkWalletCanceled:
      state.unlinkAlert = nil
      return .none
      
    case .settingsProfileAction(let action):
      switch action {
        
      }
  }
}
