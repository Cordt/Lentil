// Lentil

import ComposableArchitecture
import SwiftUI

struct ProfilePicture: ReducerProtocol {
  struct State: Equatable {
    var handle: String
    var pictureUrl: URL?
    var picture: Image?
  }
  
  enum Action: Equatable {
    case fetchProfilePicture
    case updateProfilePicture(TaskResult<Image?>)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .fetchProfilePicture:
        return .task { [url = state.pictureUrl] in
          await .updateProfilePicture(
            TaskResult {
              if let url {
                return try await lensApi.getProfilePicture(url)
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
}
