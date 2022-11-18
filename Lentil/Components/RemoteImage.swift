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
    case updateImage(TaskResult<Image?>)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .fetchImage:
        return .task { [url = state.imageUrl] in
          await .updateImage(
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
        
      case .updateImage(let .success(image)):
        state.image = image
        return .none
        
      case .updateImage(.failure):
        // Handle error
        return .none
    }
  }
}
