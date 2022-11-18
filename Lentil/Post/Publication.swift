// Lentil
// Created by Laura and Cordt Zermin

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
    
    var publicationImage: Image?
    var remotePublicationImage: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.publication.media.first?.url,
          image: self.publicationImage
        )
      }
      set {
        self.publicationImage = newValue.image
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
    case remotePublicationImage(RemoteImage.Action)
    case toggleReaction
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      RemoteImage()
    }
    
    Scope(state: \.remotePublicationImage, action: /Action.remotePublicationImage) {
      RemoteImage()
    }
    
    Reduce { state, action in
      switch action {
        case .remoteProfilePicture:
          return .none
          
        case .remotePublicationImage:
          return .none
          
        case .toggleReaction:
          guard let userProfile = self.profileStorageApi.load()
          else { return .none }
          
          if state.publication.upvotedByUser {
            state.publication.upvotes -= 1
            state.publication.upvotedByUser = false
            return .fireAndForget { [publicationId = state.publication.id] in
              try await self.lensApi.removeReaction(userProfile.id, .upvote, publicationId)
            }
          }
          else {
            state.publication.upvotes += 1
            state.publication.upvotedByUser = true
            return .fireAndForget { [publicationId = state.publication.id] in
              try await self.lensApi.addReaction(userProfile.id, .upvote, publicationId)
            }
          }
      }
    }
  }
}
