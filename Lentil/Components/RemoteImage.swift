// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI

struct RemoteImage: ReducerProtocol {
  struct State: Equatable {
    var imageUrl: URL?
    var image: Image?
  }
  
  enum Action: Equatable {
    case fetchImage
    case updateProfilePicture(TaskResult<Image?>)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .fetchImage:
        return .task { [url = state.imageUrl] in
          await .updateProfilePicture(
            TaskResult {
              if let url {
                return try await lensApi.fetchImage(url)
              }
              else {
                return nil
              }
            }
          )
        }
        
      case .updateProfilePicture(let .success(profilePicture)):
        state.image = profilePicture
        return .none
        
      case .updateProfilePicture(.failure):
        // Handle error
        return .none
    }
  }
}
