// Lentil

import ComposableArchitecture
import SwiftUI


struct Publication: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var publication: Model.Publication
    
    var profilePicture: Image?
    var remoteProfilePicture: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.publication.profilePictureUrl,
          image: self.profilePicture
        )
      }
      set {
        self.profilePicture = newValue.image
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
    case remoteProfilePicture(RemoteImage.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      RemoteImage()
    }
    
    Reduce { state, action in
      switch action {
        case .remoteProfilePicture:
          return .none
      }
    }
  }
}
