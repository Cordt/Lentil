// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Foundation
import PhotosUI
import SwiftUI


struct CreatePublication: ReducerProtocol {
  struct State: Equatable {
    enum Reason: Equatable, Hashable {
      case creatingPost
      case replyingToPost(_ postId: String, _ of: String)
      case replyingToComment(_ commentId: String, _ of: String)
    }
    
    struct Gif: Equatable {
      var previewURL: URL
      var displayURL: URL
    }
    
    var navigationId: String
    var reason: Reason
    var publicationText: String = ""
    var isPosting: Bool = false
    var cancelAlert: AlertState<Action>?
    
    var photoPickerItem: PhotosPickerItem?
    var selectedPhoto: UIImage?
    var selectGif: GifController.State?
    var selectedGif: Gif?
    
    var placeholder: String {
      switch self.reason {
        case .creatingPost:       return "Share your thoughts!"
        case .replyingToPost:     return "Share your reply!"
        case .replyingToComment:  return "Share your reply!"
      }
    }
  }
  
  enum Action: Equatable {
    case dismissView(_ txHash: String?)
    case publicationTextChanged(String)
    case didTapCancel
    case discardAndDismiss
    case cancelAlertDismissed
    case createPublication
    case createPublicationResponse(TaskResult<Result<RelayerResult, RelayErrorReasons>>)
    
    case photoSelectionTapped(PhotosPickerItem?)
    case photoSelected(TaskResult<UIImage>)
    case deleteImageTapped
    case selectGifTapped
    case selectGif(GifController.Action)
    case setSelectGif(GifController.State?)
    case deleteGifTapped
  }
  
  @Dependency(\.infuraApi) var infuraApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocolOf<CreatePublication> {
    Reduce { state, action in
      switch action {
        case .dismissView:
          self.navigationApi.remove(
            DestinationPath(
              navigationId: state.navigationId,
              destination: .createPublication(state.reason)
            )
          )
          return .none
          
        case .publicationTextChanged(let text):
          state.publicationText = text
          return .none
          
        case .didTapCancel:
          if state.publicationText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return Effect(value: .discardAndDismiss)
          }
          else {
            state.cancelAlert = AlertState(
              title: TextState("Are you sure you want to discard your draft?"),
              message: TextState("When you discard, the content of your draft publication will be lost."),
              primaryButton: .cancel(TextState("Continue")),
              secondaryButton: .destructive(TextState("Discard"), action: .send(.discardAndDismiss))
            )
            return .none
          }
          
        case .discardAndDismiss:
          state.publicationText = ""
          return Effect(value: .dismissView(nil))
          
        case .cancelAlertDismissed:
          state.cancelAlert = nil
          return .none
          
        case .createPublication:
          guard state.publicationText.trimmingCharacters(in: .whitespacesAndNewlines) != "",
                let userProfile = self.profileStorageApi.load()
          else { return .none}
          
          state.isPosting = true
          
          return .task { [reason = state.reason, publicationText = state.publicationText, selectedPhoto = state.selectedPhoto, selectedGif = state.selectedGif] in
            let name = "lentil-" + uuid.callAsFunction().uuidString
            let publicationUrl = URL(string: "https://lentilapp.xyz/publication/\(name)")
            var description: String
            if case .creatingPost = reason { description = "Post by \(userProfile.handle) via lentil" }
            else { description = "Comment by \(userProfile.handle) via lentil" }
            
            var media: [Metadata.Medium] = []
            if let imageData = selectedPhoto?.imageData(for: .feed, and: .storage) {
              let imageFile = ImageFile(imageData: imageData, mimeType: .jpeg)
              let infuraImageResult = try await self.infuraApi.uploadImage(imageFile)
              let contentUri = "ipfs://\(infuraImageResult.Hash)"
              media.append(Metadata.Medium(item: contentUri, type: .jpeg))
            }
            
            if let gifURL = selectedGif?.displayURL {
              media.append(Metadata.Medium(item: gifURL.absoluteString, type: .gif))
            }
            
            let publicationFile = try PublicationFile(
              metadata: Metadata(
                version: .two,
                metadata_id: name,
                description: description,
                content: publicationText,
                locale: .english,
                tags: [],
                contentWarning: nil,
                mainContentFocus: media.count > 0 ? .image : .text_only,
                external_url: publicationUrl,
                name: name,
                attributes: [],
                image: LentilEnvironment.shared.lentilIconIPFSUrl,
                imageMimeType: .jpeg,
                media: media,
                appId: LentilEnvironment.shared.lentilAppId
              ),
              name: name
            )
            
            let infuraPublicationResult = try await self.infuraApi.uploadPublication(publicationFile)
            
            return await .createPublicationResponse(
              TaskResult {
                let contentUri = "ipfs://\(infuraPublicationResult.Hash)"
                switch reason {
                  case .creatingPost:
                    return try await self.lensApi.createPost(userProfile.id, contentUri)
                  case .replyingToPost(let postId, _):
                    return try await self.lensApi.createComment(userProfile.id, postId, contentUri)
                  case .replyingToComment(let commentId, _):
                    return try await self.lensApi.createComment(userProfile.id, commentId, contentUri)
                }
              }
            )
          }
          
        case .createPublicationResponse(.success(let result)):
          switch result {
            case .success(let relayerResult):
              state.publicationText = ""
              state.isPosting = false
              log("Successfully created publication: Hash: \(relayerResult.txnHash), Id: \(relayerResult.txnId)", level: .info)
              return Effect(value: .dismissView(relayerResult.txnHash))
              
            case .failure(let error):
              state.isPosting = false
              log("Failed to create publication", level: .error, error: error)
              return .none
          }
          
        case .createPublicationResponse(.failure(let error)):
          state.isPosting = false
          log("Failed to create publication", level: .error, error: error)
          return .none
          
        case .photoSelectionTapped(let item):
          state.photoPickerItem = item
          if let item {
            return .task {
              guard let data = try await item.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data)
              else { return .photoSelected(.failure(PHPhotosError(.invalidResource))) }
              return await .photoSelected(TaskResult { uiImage })
            }
          }
          else {
            return .none
          }
          
        case .photoSelected(.success(let image)):
          state.selectedPhoto = image
          return .none
          
        case .photoSelected(.failure(let error)):
          log("Failed to load image from PhotoSelection", level: .error, error: error)
          return .none
          
        case .deleteImageTapped:
          state.selectedPhoto = nil
          return .none
          
        case .selectGifTapped:
          state.selectGif = GifController.State()
          return .none
          
        case .selectGif(let gifControllerAction):
          if case .dismiss = gifControllerAction {
            state.selectGif = nil
          }
          else if case .didSelectMedia(let media) = gifControllerAction {
            if let previewURLString = media.url(rendition: .fixedWidthSmall, fileType: .gif),
               let displayURLString = media.url(rendition: .fixedWidth, fileType: .gif),
               let previewURL = URL(string: previewURLString),
               let displayURL = URL(string: displayURLString)
            {
              state.selectedGif = CreatePublication.State.Gif(previewURL: previewURL, displayURL: displayURL)
            }
            state.selectGif = nil
          }
          return .none
          
        case .setSelectGif(let gifState):
          state.selectGif = gifState
          return .none
          
        case .deleteGifTapped:
          state.selectedGif = nil
          return .none
          
      }
    }
    .ifLet(\.selectGif, action: /Action.selectGif) {
      GifController()
    }
  }
}
