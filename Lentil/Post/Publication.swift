// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct Publication: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: String { self.publication.id }
    var publication: Model.Publication
    var remoteProfilePicture: LentilImage.State?
    var remotePublicationImage: LentilImage.State?
    
    var publicationContent: String { self.publication.content.trimmingCharacters(in: .whitespacesAndNewlines) }
    var shortenedContent: String {
      if self.publicationContent.count > Theme.maxPostLength {
        return String(self.publicationContent.prefix(Theme.maxPostLength)) + "..."
      }
      else {
        return self.publicationContent
      }
    }
    
    init(publication: Model.Publication) {
      self.publication = publication
      self.remoteProfilePicture = nil
      self.remotePublicationImage = nil
      
      if let profilePictureUrl = publication.profile.profilePictureUrl {
        self.remoteProfilePicture = .init(imageUrl: profilePictureUrl, kind: .profile(publication.profile.handle))
      }
      if let publicationImageUrl = publication.media.first?.url {
        self.remotePublicationImage = .init(imageUrl: publicationImageUrl, kind: .feed)
      }
    }
  }
  
  enum Action: Equatable {
    case userProfileTapped
    case remotePublicationImage(LentilImage.Action)
    case toggleReaction
    case commentTapped
    
    case remoteProfilePicture(LentilImage.Action)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
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
            self.cache.updateOrAppendPublication(state.publication)
            return .fireAndForget { [publicationId = state.publication.id] in
              try await self.lensApi.removeReaction(userProfile.id, .upvote, publicationId)
            }
          }
          else {
            state.publication.upvotes += 1
            state.publication.upvotedByUser = true
            self.cache.updateOrAppendPublication(state.publication)
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
    .ifLet(\.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      LentilImage()
    }
    .ifLet(\.remotePublicationImage, action: /Action.remotePublicationImage) {
      LentilImage()
    }
  }
}
