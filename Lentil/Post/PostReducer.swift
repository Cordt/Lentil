// Lentil

import ComposableArchitecture
import SwiftUI


struct PostState: Equatable, Identifiable {
  var post: Publication
  var profilePicture: Image?
  
  private let maxLength: Int = 256
  
  var postContent: String {
    if self.post.content.count > self.maxLength {
      return String(self.post.content.prefix(self.maxLength)) + "..."
    }
    else {
      return self.post.content
    }
  }
  
  var id: String { self.post.id }
}

enum PostAction: Equatable {
  case fetchProfilePicture
  case updateProfilePicture(TaskResult<Image>)
}

let postReducer = Reducer<PostState, PostAction, AppEnvironment> { state, action, env in
  switch action {
    case .fetchProfilePicture:
      return .task { [url = state.post.profilePictureUrl] in
        await .updateProfilePicture(
          TaskResult { try await env.lensApi.getProfilePicture(url) }
        )
      }
      
    case .updateProfilePicture(let .success(profilePicture)):
      state.profilePicture = profilePicture
      return .none
      
    case .updateProfilePicture(.failure):
      // Handle error
      return .none
  }
}
