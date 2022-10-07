// Lentil

import ComposableArchitecture
import Foundation


struct SettingsState: Equatable {
  var walletState: WalletState?
  
  var isLinkWalletPresented: Bool = false
  var privateKeyTextField = ProcessInfo.processInfo.environment["TEST_WALLET_PRIVATE_KEY"]!
  var passwordTextField = ProcessInfo.processInfo.environment["TEST_WALLET_PASSWORD"]!
  
  var isLoadWalletPresented: Bool = false
  var loadWalletPasswordTextField = ""
}

enum SettingsAction: Equatable {
  case wallet(_ action: WalletAction)
  
  case didAppear
  
  case linkWalletTapped
  case setLinkWallet(isPresented: Bool)
  case privateKeyTextChanged(text: String)
  case passwordTextChanged(text: String)
  
  case requestLoadWallet
  case setLoadWallet(isPresented: Bool)
  case loadWalletPasswordTextChanged(text: String)
  
  case loadWallet
  case linkWallet
  case unlinkWallet
  
}

struct SettingsEnvironment {
  let lensApi: LensApi
  let walletExists: () throws -> Bool
  let fetchWallet: (_ password: String) throws -> Wallet
  let createWallet: (_ privateKey: String, _ password: String) throws -> Wallet
}

extension SettingsEnvironment {
  static var live: SettingsEnvironment {
    SettingsEnvironment(
      lensApi: .live,
      walletExists: Wallet.hasAccount,
      fetchWallet: Wallet.init,
      createWallet: Wallet.init
    )
  }
  
#if DEBUG
  static var mock: SettingsEnvironment {
    SettingsEnvironment(
      lensApi: .mock,
      walletExists: { true },
      fetchWallet: { _ in testWallet },
      createWallet: { _, _ in testWallet }
    )
  }
#endif
}

let settingsReducer =
walletReducer
  .optional()
  .pullback(
    state: \.walletState,
    action: /SettingsAction.wallet,
    environment: { $0 }
  )
  .combined(
    with: Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, env in
      switch action {
        case .didAppear:
          do {
            if try env.walletExists() {
              return .task {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
                return .requestLoadWallet
              }
            }
          } catch let error {
            print("[ERROR] \(error.localizedDescription)")
            // TODO: User feedback
          }
          return .none
          
        case .linkWalletTapped:
          state.isLinkWalletPresented = true
          return .none
          
        case .setLinkWallet(let isPresented):
          state.isLinkWalletPresented = isPresented
          return .none
          
        case .privateKeyTextChanged(let text):
          state.privateKeyTextField = text
          return .none
          
        case .passwordTextChanged(let text):
          state.passwordTextField = text
          return .none
          
        case .requestLoadWallet:
          state.isLoadWalletPresented = true
          return .none
          
        case .setLoadWallet(let isPresented):
          state.isLoadWalletPresented = isPresented
          return .none
          
        case .loadWalletPasswordTextChanged(let text):
          state.loadWalletPasswordTextField = text
          return .none
          
          
        case .linkWallet:
          do {
            state.walletState = WalletState(
              wallet: try env.createWallet(state.privateKeyTextField, state.passwordTextField),
              settingsProfileState: nil
            )
           
            state.isLinkWalletPresented = false
            return Effect(value: .wallet(.fetchDefaultProfile))
            
          } catch let error {
            print("[ERROR] \(error.localizedDescription)")
            // TODO: User feedback
          }
          return .none
          
        case .loadWallet:
          do {
            state.walletState = WalletState(
              wallet: try env.fetchWallet(state.loadWalletPasswordTextField),
              settingsProfileState: SettingsProfileState(profile: mockProfiles[2])
            )
            
            state.isLoadWalletPresented = false
            return Effect(value: .wallet(.fetchDefaultProfile))
            
          } catch let error {
            print("[ERROR] \(error.localizedDescription)")
            // TODO: User feedback
          }
          
          return .none
          
        case .unlinkWallet:
          guard let walletState = state.walletState
          else { return .none }
          
          state.walletState = nil
          do {
            try Wallet.removeAccount()
          } catch let error {
            print("[ERROR] \(error.localizedDescription)")
            // TODO: User feedback
          }
          return .none
          
        case .wallet(let walletAction):
          switch walletAction {
            case .fetchDefaultProfile, .defaultProfileResponse:
              return .none
              
            case .unlinkWalletTapped, .unlinkWalletCanceled:
              return .none
              
            case .unlinkWalletConfirmed:
              return Effect(value: .unlinkWallet)
          }
          
      }
    }
  )
