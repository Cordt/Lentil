// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Publication: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: String { self.publication.id }
    var profilePicture: Image?
    var remoteProfilePicture: RemoteImage.State {
      get {
        RemoteImage.State(imageUrl: self.publication.profile.profilePictureUrl)
      }
      set {
        self.profilePicture = newValue.image
      }
    }
    
    var publication: Model.Publication
    var publicationImage: Image?
    var remotePublicationImage: RemoteImage.State {
      get {
        RemoteImage.State(imageUrl: self.publication.media.first?.url)
      }
      set {
        self.publicationImage = newValue.image
      }
    }
    
    var publicationContent: String { self.publication.content.trimmingCharacters(in: .whitespacesAndNewlines) }
    var shortenedContent: String {
      if self.publicationContent.count > Theme.maxPostLength {
        return String(self.publicationContent.prefix(Theme.maxPostLength)) + "..."
      }
      else {
        return self.publicationContent
      }
    }
  }
  
  enum Action: Equatable {
    case userProfileTapped
    case remotePublicationImage(RemoteImage.Action)
    case toggleReaction
    case commentTapped
    
    case remoteProfilePicture(RemoteImage.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      RemoteImage()
    }
    
    Scope(state: \.remotePublicationImage, action: /Action.remotePublicationImage) {
      RemoteImage()
    }
    
    Reduce { state, action in
      switch action {
        case .userProfileTapped:
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .profile(state.publication.profile.id)
            )
          )
          return .none
          
        case .remotePublicationImage:
          return .none
          
        case .toggleReaction:
          guard let userProfile = self.profileStorageApi.load()
          else { return .none }
          
          if state.publication.upvotedByUser {
            state.publication.upvotes -= 1
            state.publication.upvotedByUser = false
            publicationsCache[id: state.publication.id] = state.publication
            return .fireAndForget { [publicationId = state.publication.id] in
              try await self.lensApi.removeReaction(userProfile.id, .upvote, publicationId)
            }
          }
          else {
            state.publication.upvotes += 1
            state.publication.upvotedByUser = true
            publicationsCache[id: state.publication.id] = state.publication
            return .fireAndForget { [publicationId = state.publication.id] in
              try await self.lensApi.addReaction(userProfile.id, .upvote, publicationId)
            }
          }
          
        case .commentTapped:
          guard self.profileStorageApi.load() != nil
          else { return .none }
          
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .createPublication(.replyingToPost(state.id, state.publication.profile.handle))
            )
          )
          return .none
       
        case .remoteProfilePicture:
          return .none
      }
    }
  }
}
