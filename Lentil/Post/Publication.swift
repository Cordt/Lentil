// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import IdentifiedCollections
import SwiftUI


struct Publication: ReducerProtocol {
  struct State: Equatable, Identifiable {
    struct MirrorConfirmationDialogue: Equatable {
      var profileHandle: String
      var action: Action
    }
    
    var id: String { self.publication.id }
    var publication: Model.Publication
    var remoteProfilePicture: LentilImage.State?
    var remotePublicationImages: MultiImage.State?
    var publicationImageHeight: CGFloat {
      guard let count = self.remotePublicationImages?.images.count
      else { return 0 }
      switch count {
        case 0:   return 0
        case 1:   return 250
        case 2:   return 125
        case 3:   return 375
        case 4:   return 250
        case 5:   return 500
        default:  return 0
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
    
    var mirrorConfirmationDialogue: MirrorConfirmationDialogue?
    
    init(publication: Model.Publication) {
      self.publication = publication
      self.remoteProfilePicture = nil
      self.remotePublicationImages = nil
      self.mirrorConfirmationDialogue = nil
      
      if let profilePictureUrl = publication.profile.profilePictureUrl {
        self.remoteProfilePicture = .init(imageUrl: profilePictureUrl, kind: .profile(publication.profile.handle))
      }
      if publication.media.count > 0 {
        let imageStates = publication.media
          .map { LentilImage.State(imageUrl: $0.url, kind: .feed) }
        var uniqueImageStates: [LentilImage.State] = []
        imageStates.forEach {
          if !uniqueImageStates.contains($0) { uniqueImageStates.append($0) }
        }
        self.remotePublicationImages = .init(images: IdentifiedArrayOf(uniqueElements: uniqueImageStates))
      }
    }
  }
  
  indirect enum Action: Equatable {
    case userProfileTapped
    case toggleReaction
    case commentTapped
    case mirrorTapped
    
    case mirrorConfirmationSet(State.MirrorConfirmationDialogue?)
    case mirrorConfirmationConfirmed
    case mirrorResult(TaskResult<Result<RelayerResult, RelayErrorReasons>>)
    case mirrorSuccess(_ txnHash: String)
    
    case remoteProfilePicture(LentilImage.Action)
    case remotePublicationImages(MultiImage.Action)
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
          
        case .remotePublicationImages:
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
          
        case .mirrorTapped:
          guard self.profileStorageApi.load() != nil
          else { return .none }
          
          state.mirrorConfirmationDialogue = State.MirrorConfirmationDialogue(
            profileHandle: state.publication.profile.handle,
            action: .mirrorConfirmationConfirmed
          )
          return .none
          
        case .mirrorConfirmationSet(let confirmationState):
          state.mirrorConfirmationDialogue = confirmationState
          return .none
          
        case .mirrorConfirmationConfirmed:
          guard let user = self.profileStorageApi.load()
          else { return .none }
          
          return .task { [publicationId = state.publication.id] in
            await .mirrorResult(
              TaskResult { try await self.lensApi.createMirror(user.id, publicationId) }
            )
          }
          
        case .mirrorResult(.success(let result)):
          switch result {
            case .success(let relayerResult):
              log("Successfully mirrored publication", level: .info)
              return Effect(value: .mirrorSuccess(relayerResult.txnHash))
              
            case .failure(let relayerError):
              log("Failed to mirror publication", level: .error, error: relayerError)
          }
          return .none
          
        case .mirrorResult(.failure(let error)):
          log("Failed to mirror publication", level: .error, error: error)
          return .none
          
        case .mirrorSuccess:
          return .none
       
        case .remoteProfilePicture:
          return .none
      }
    }
    .ifLet(\.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      LentilImage()
    }
    .ifLet(\.remotePublicationImages, action: /Action.remotePublicationImages) {
      MultiImage()
    }
  }
}
