// Lentil

import ComposableArchitecture
import SwiftUI

struct ProfilePictureState: Equatable {
  var handle: String
  var pictureUrl: URL?
  var picture: Image?
}

enum ProfilePictureAction: Equatable {
  case fetchProfilePicture
  case updateProfilePicture(TaskResult<Image?>)
}

let profileReducer: Reducer<ProfilePictureState, ProfilePictureAction, RootEnvironment> = Reducer { state, action, env in
  switch action {
    case .fetchProfilePicture:
      return .task { [url = state.pictureUrl, handle = state.handle] in
        await .updateProfilePicture(
          TaskResult {
            if let url {
              return try await env.lensApi.getProfilePicture(url)
            }
            else {
              return nil
            }
          }
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
