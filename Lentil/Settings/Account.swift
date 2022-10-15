// Lentil

import ComposableArchitecture
import Foundation


struct Account: ReducerProtocol {
  struct State: Equatable {
    var unlinkAlert: AlertState<Action>?
    var authenticated: Bool = false
    var addressShort: String = ""
    
    var walletProfilesState: WalletProfiles.State?
  }
  
  enum Action: Equatable {
    case fetchProfiles
    case profilesResponse([Model.Profile])
    
    case unlinkWalletTapped
    case unlinkWalletConfirmed
    case unlinkWalletCanceled
    
    case authenticateTapped
    case authenticationChallenge(TaskResult<String>)
    case authenticationChallengeResponse(TaskResult<AuthenticationTokens>)
    
    case walletProfilesAction(WalletProfiles.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.walletApi) var walletApi
  
  var body: some ReducerProtocol<State, Action> {
    Reduce<State, Action> { state, action in
      do {
        let wallet = try walletApi.getWallet()
        state.addressShort = wallet.addressShort
        
        switch action {
          case .fetchProfiles:
            return .concatenate(
              Effect(value: .authenticateTapped),
              .run { send in
                let profiles = try await lensApi.profiles(wallet.address).data
                await send(.profilesResponse(profiles), animation: .easeIn)
              }
            )
            
          case .profilesResponse(let profiles):
            let profilesState = profiles
              .enumerated()
              .map { WalletProfile.State(profile: $0.element, isLast: $0.offset == profiles.count - 1) }
            state.walletProfilesState = .init(profiles: .init(uniqueElements: profilesState))
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
            
          case .authenticateTapped:
            authenticationTokens = nil
            return .task {
              await .authenticationChallenge(
                TaskResult {
                  try await lensApi.authenticationChallenge(wallet.address).data
                }
              )
            }
            
          case .authenticationChallenge(.success(let challenge)):
            print("[INFO] Trying to sign challenge: \(challenge)")
            return .task {
              let signature = try wallet.sign(message: challenge)
              return await .authenticationChallengeResponse(
                TaskResult {
                  try await lensApi.authenticate(wallet.address, signature).data
                }
              )
            }
            
          case .authenticationChallengeResponse(.success(let tokens)):
            // FIXME: It's a little embarrassing, but works for the moment 😬
            // The tokens should be stored properly in the keychain, not as a global AND
            // the user should be asked to sign the transaction properly, otherwise
            // the whole wallet is at risk when the API is compromised
            if ProcessInfo.processInfo.environment["DEBUG_LEVEL"]! == "INFO" {
              print("[INFO] Successfully retrieved tokens: \(tokens)")
            }
            authenticationTokens = tokens
            state.authenticated = true
            return .none
            
          case .authenticationChallenge(.failure(let error)):
            print("[ERROR] Could not retrieve challenge to authenticate: \(error)")
            return .none
            
          case .authenticationChallengeResponse(.failure(let error)):
            print("[ERROR] Could not retrieve tokens for signature: \(error)")
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
      catch let walletError {
        print("[ERROR] Could not load wallet in Account context: \(walletError)")
        return .none
      }
    }
    .ifLet(\.walletProfilesState, action: /Action.walletProfilesAction) {
      WalletProfiles()
    }
  }
}
