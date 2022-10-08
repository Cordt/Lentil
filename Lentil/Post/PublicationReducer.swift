// Lentil

import ComposableArchitecture


struct PublicationState: Equatable, Identifiable {
  var publication: Publication
  
  var profile: ProfilePictureState {
    get {
      ProfilePictureState(
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

enum PublicationAction: Equatable {
  case profile(ProfilePictureAction)
}

let publicationReducer: Reducer<PublicationState, PublicationAction, RootEnvironment> = Reducer { state, action, env in
  switch action {
    case .profile(_):
      return .none
  }
}
