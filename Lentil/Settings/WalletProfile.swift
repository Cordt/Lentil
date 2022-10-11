// Lentil

import ComposableArchitecture


struct WalletProfile: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var wallet: Wallet
    var id: String { self.profile.id }
    var profile: Profile
    var isLast: Bool = false
    
    var signTransaction: SignTransaction.State?
  }
  
  enum Action: Equatable {
    case defaultProfileToggled(_ active: Bool)
    case defaultProfileTnxResult(_ result: TaskResult<MutationResult<Result<Broadcast, RelayErrorReasons>>>)
    
    case requestSignature(SignTransaction.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .defaultProfileToggled:
          return .none
          
        case .defaultProfileTnxResult(let result):
          switch result {
            case .success(let mutationResult):
              switch mutationResult.data {
                case .success(let broadcast):
                  print("Successfully broadcasted:\n\(broadcast.txnHash)\n\(broadcast.txnId)")
                case .failure(let error):
                  print("[ERROR] Failed to broadcase transaction: \(error)")
              }
            case .failure(let error):
              print("[ERROR] Failed to broadcase transaction: \(error)")
          }
          return .none
          
        case .requestSignature(let signatureAction):
          switch signatureAction {
            case .setSheetPresented(let present):
              if !present { state.signTransaction = nil }
              return .none
              
            case .rejectTransaction:
              return Effect(
                value: .requestSignature(
                  .setSheetPresented(false)
                )
              )
              
            case .signTransaction:
              guard let txnState = state.signTransaction
              else { return .none }
              
              return .task { [wallet = state.wallet] in
                await .defaultProfileTnxResult(
                  TaskResult {
                    let signedMessage = try wallet.sign(message: txnState.typedDataResult.typedData)
                    return try await lensApi.broadcast(txnState.typedDataResult.id, signedMessage)
                  }
                )
              }
          }
      }
    }
    .ifLet(
      \.signTransaction,
       action: /Action.requestSignature,
       then: { SignTransaction() }
    )
  }
}
