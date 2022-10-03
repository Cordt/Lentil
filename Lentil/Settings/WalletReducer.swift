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
  
  var settingsProfileState: SettingsProfileState
}

enum WalletAction: Equatable {
  case unlinkWalletTapped
  case unlinkWalletConfirmed
  case unlinkWalletCanceled
  
  case settingsProfileAction(SettingsProfileAction)
}

let walletReducer: Reducer<WalletState, WalletAction, Void> = Reducer { state, action, _ in
  switch action {
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
