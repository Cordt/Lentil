// Lentil

import ComposableArchitecture
import SwiftUI

struct ProfileState: Equatable {
  var handle: String
  var pictureUrl: URL
  var picture: Image?
}

enum ProfileAction: Equatable {
  case fetchProfilePicture
  case updateProfilePicture(TaskResult<Image>)
}

let profileReducer: Reducer<ProfileState, ProfileAction, RootEnvironment> = Reducer { state, action, env in
  switch action {
    case .fetchProfilePicture:
      return .task { [url = state.pictureUrl] in
        await .updateProfilePicture(
          TaskResult { try await env.lensApi.getProfilePicture(url) }
        )
      }
      
    case .updateProfilePicture(let .success(profilePicture)):
      state.picture = profilePicture
      return .none
      
    case .updateProfilePicture(.failure):
      // Handle error
      return .none
  }
}
