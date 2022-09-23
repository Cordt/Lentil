// Lentil

import ComposableArchitecture
import SwiftUI


struct PostState: Equatable, Identifiable {
  var post: Publication
  
  var profile: ProfileState {
    get {
      ProfileState(
        handle: self.post.profileHandle,
        pictureUrl: self.post.profilePictureUrl
      )
    }
  }
  
  private let maxLength: Int = 256
  var id: String { self.post.id }
  var postContent: String {
    if self.post.content.count > self.maxLength {
      return String(self.post.content.prefix(self.maxLength)) + "..."
    }
    else {
      return self.post.content
    }
  }
}

enum PostAction: Equatable {
  case profile(ProfileAction)
}

let postReducer = Reducer<PostState, PostAction, RootEnvironment> { state, action, env in
  switch action {
    case .profile(_):
      return .none
  }
}
