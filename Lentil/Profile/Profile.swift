// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Profile: ReducerProtocol {
  struct State: Equatable {
    var profile: Model.Profile
    
    var coverPicture: Image?
    var remoteCoverPicture: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.profile.coverPictureUrl,
          image: self.coverPicture
        )
      }
      set {
        self.coverPicture = newValue.image
      }
    }
    var profilePicture: Image?
    var remoteProfilePicture: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.profile.profilePictureUrl,
          image: self.profilePicture
        )
      }
      set {
        self.profilePicture = newValue.image
      }
    }
  }
  
  enum Action: Equatable {
    case remoteCoverPicture(RemoteImage.Action)
    case remoteProfilePicture(RemoteImage.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.remoteCoverPicture, action: /Action.remoteCoverPicture) {
      RemoteImage()
    }
    Scope(state: \.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      RemoteImage()
    }
    
    Reduce { state, action in
      switch action {
        case .remoteCoverPicture, .remoteProfilePicture:
          return .none
      }
    }
  }
}
