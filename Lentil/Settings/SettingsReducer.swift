// Lentil

import ComposableArchitecture
import Foundation



struct Settings: ReducerProtocol {
  struct State: Equatable {
    var accountState: Account.State?
    
    var isLinkWalletPresented: Bool = false
    var privateKeyTextField = ProcessInfo.processInfo.environment["TEST_WALLET_PRIVATE_KEY"]!
    var passwordTextField = ProcessInfo.processInfo.environment["TEST_WALLET_PASSWORD"]!
    
    var isLoadWalletPresented: Bool = false
    var loadWalletPasswordTextField = ""
  }
  
  enum Action: Equatable {
    case accountAction(_ action: Account.Action)
    
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
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.walletApi) var walletApi
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          do {
            if try walletApi.walletExists() {
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
            state.accountState = Account.State(
              wallet: try walletApi.createWallet(state.privateKeyTextField, state.passwordTextField),
              walletProfilesState: nil
            )
            
            state.isLinkWalletPresented = false
            return Effect(value: .accountAction(.fetchProfiles))
            
          } catch let error {
            print("[ERROR] \(error.localizedDescription)")
            // TODO: User feedback
          }
          return .none
          
        case .loadWallet:
          do {
            state.accountState = Account.State(
              wallet: try walletApi.fetchWallet(state.loadWalletPasswordTextField),
              walletProfilesState: nil
            )
            
            state.isLoadWalletPresented = false
            return Effect(value: .accountAction(.fetchProfiles))
            
          } catch let error {
            print("[ERROR] \(error.localizedDescription)")
            // TODO: User feedback
          }
          
          return .none
          
        case .unlinkWallet:
          guard state.accountState != nil
          else { return .none }
          
          state.accountState = nil
          do {
            try Wallet.removeAccount()
          } catch let error {
            print("[ERROR] \(error.localizedDescription)")
            // TODO: User feedback
          }
          return .none
          
        case .accountAction(let walletAction):
          switch walletAction {
            case .fetchProfiles, .profilesResponse:
              return .none
              
            case .unlinkWalletTapped, .unlinkWalletCanceled:
              return .none
              
            case .unlinkWalletConfirmed:
              return Effect(value: .unlinkWallet)
              
            case .authenticateTapped, .authenticationChallenge, .authenticationChallengeResponse:
              return .none
              
            case .walletProfilesAction:
              return .none
          }
          
      }
    }
    .ifLet(\.accountState, action: /Action.accountAction) {
      Account()
    }
  }
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
