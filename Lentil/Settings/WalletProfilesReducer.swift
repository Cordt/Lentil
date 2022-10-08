// Lentil

import ComposableArchitecture


struct WalletProfilesState: Equatable {
  var setDefaultProfileConfirmationDialogue: ConfirmationDialogState<WalletProfilesAction>?
  
  var profiles: IdentifiedArrayOf<WalletProfileState>
}

enum WalletProfilesAction: Equatable {
  case setDefaultProfile(_ id: TaskResult<String>)
  case confirmSetDefaultProfile(_ id: String)
  case cancelSetDefaultProfile
  
  case profileAction(_ id: WalletProfileState.ID, _ profile: WalletProfileAction)
}

let walletProfilesReducer: Reducer<WalletProfilesState, WalletProfilesAction, RootEnvironment> = Reducer.combine(
  walletProfileReducer
    .forEach(
      state: \.profiles,
      action: /WalletProfilesAction.profileAction,
      environment: { _ in () }
    ),
  
  Reducer<WalletProfilesState, WalletProfilesAction, RootEnvironment> { state, action, env in
    switch action {
      case .setDefaultProfile(.success(let id)):
        state.profiles[id: id]?.profile.isDefault = true
        return .none
        
      case .setDefaultProfile(.failure(let error)):
        print("[WARN] Could not set default profile: \(error.localizedDescription)")
        return .none
        
      case .confirmSetDefaultProfile(let id):
        guard let selectedProfile = state.profiles[id: id]?.profile
        else { return .none }
        
        return .task {
          await .setDefaultProfile(
            TaskResult {
              try await env.lensApi.setDefaultProfile(selectedProfile.ownedBy)
              return id
            }
          )
        }
        
      case .cancelSetDefaultProfile:
        state.setDefaultProfileConfirmationDialogue = nil
        return .none
        
      case .profileAction(let id, let profilesAction):
        switch profilesAction {
          case .defaultProfileToggled(let active):
            guard let selectedProfile = state.profiles[id: id]?.profile
            else { return .none }
            
            let hasOtherDefaultProfile = state.profiles.reduce(false) { current, next in
              (next.profile.id == id) ? current : current || next.profile.isDefault
            }
            
            if active {
              if hasOtherDefaultProfile {
                // User has another default profile - show dialogue to confirm change
                state.setDefaultProfileConfirmationDialogue = ConfirmationDialogState(
                  title: TextState("Do you really want to change your default profile?"),
                  message: TextState("This will set a new default profile that replaces the current"),
                  buttons: [
                    .cancel(TextState("Cancel"), action: .send(.cancelSetDefaultProfile)),
                    .default(TextState("Confirm"), action: .send(.confirmSetDefaultProfile(id)))
                  ]
                )
                return .none
              }
              else {
                // User has no other default profile - try to set it
                return .task {
                  await .setDefaultProfile(
                    TaskResult {
                      try await env.lensApi.setDefaultProfile(selectedProfile.ownedBy)
                      return id
                    }
                  )
                }
              }
            }
            else {
              // The API does not allow to have no default profile - show alert
              return .none
            }
        }
    }
  }
)
