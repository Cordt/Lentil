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
  
  var walletProfilesState: WalletProfilesState?
}

enum WalletAction: Equatable {
  case fetchProfiles
  case profilesResponse(TaskResult<[Profile]>)
  
  case unlinkWalletTapped
  case unlinkWalletConfirmed
  case unlinkWalletCanceled
  
  case walletProfilesAction(WalletProfilesAction)
}

let walletReducer = Reducer.combine(
  walletProfilesReducer
    .optional()
    .pullback(
      state: \.walletProfilesState,
      action: /WalletAction.walletProfilesAction,
      environment: { _ in .live }
    ),
  
  Reducer<WalletState, WalletAction, SettingsEnvironment> { state, action, env in
    switch action {
      case .fetchProfiles:
        return .task { [address = state.wallet.address] in
          await .profilesResponse(
            TaskResult {
              try await env.lensApi.profiles(address).data
            }
          )
        }
        
      case .profilesResponse(.success(let profiles)):
        let profilesState = profiles.map(WalletProfileState.init)
        state.walletProfilesState = .init(profiles: .init(uniqueElements: profilesState))
        return .none
        
      case .profilesResponse(.failure(let error)):
        print("[WARN] Could not fetch profiles from API: \(error)")
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
        
      case .walletProfilesAction(let action):
        switch action {
          case .setDefaultProfile, .confirmSetDefaultProfile, .cancelSetDefaultProfile:
            return .none
          case .profileAction:
            return .none
        }
    }
  }
)
