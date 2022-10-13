// Lentil

import ComposableArchitecture
import Foundation


struct Settings: ReducerProtocol {
  struct State: Equatable {
    var isLinkWalletPresented: Bool = false
    var privateKeyTextField = ProcessInfo.processInfo.environment["TEST_WALLET_PRIVATE_KEY"]!
    var passwordTextField = ProcessInfo.processInfo.environment["TEST_WALLET_PASSWORD"]!
    
    var isLoadWalletPresented: Bool = false
    var loadWalletPasswordTextField = ""
    
    var accountState: Account.State?
  }
  
  enum Action: Equatable {
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
    
    case accountAction(_ action: Account.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.walletApi) var walletApi
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          do {
            if try walletApi.keyStored() {
              return .task {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
                return .requestLoadWallet
              }
            }
          } catch let error {
            print("[ERROR] Could not access key store: \(error)")
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
            try walletApi.createWallet(state.privateKeyTextField, state.passwordTextField)
            state.accountState = Account.State(walletProfilesState: nil)
            state.isLinkWalletPresented = false
            return Effect(value: .accountAction(.fetchProfiles))
            
          } catch let error {
            print("[ERROR] Could not link wallet: \(error)")
          }
          return .none
          
        case .loadWallet:
          do {
            try walletApi.loadWallet(state.loadWalletPasswordTextField)
            state.accountState = Account.State(walletProfilesState: nil)
            state.isLoadWalletPresented = false
            return Effect(value: .accountAction(.fetchProfiles))
            
          } catch let error {
            print("[ERROR] Could not load wallet: \(error)")
          }
          
          return .none
          
        case .unlinkWallet:
          guard state.accountState != nil
          else { return .none }
          
          state.accountState = nil
          do {
            try walletApi.removeWallet()
          } catch let error {
            print("[ERROR] Could not unlink wallet: \(error)")
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
