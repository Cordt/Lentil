// Lentil

import ComposableArchitecture


struct Publication: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var publication: Model.Publication
    
    var profile: ProfilePicture.State {
      get {
        ProfilePicture.State(
          handle: self.publication.profileHandle,
          pictureUrl: self.publication.profilePictureUrl
        )
      }
    }
    
    var id: String { self.publication.id }
    private let maxLength: Int = 256
    var publicationContent: String { self.publication.content.trimmingCharacters(in: .whitespacesAndNewlines) }
    var shortenedContent: String {
      if self.publicationContent.count > self.maxLength {
        return String(self.publicationContent.prefix(self.maxLength)) + "..."
      }
      else {
        return self.publicationContent
      }
    }
  }
  
  enum Action: Equatable {
    case profile(ProfilePicture.Action)
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .profile(_):
        return .none
    }
  }
}
