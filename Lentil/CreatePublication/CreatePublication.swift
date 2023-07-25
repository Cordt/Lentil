// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Foundation
import PhotosUI
import SwiftUI


struct CreatePublication: Reducer {
  struct State: Equatable {
    enum Reason: Equatable {
      case creatingPost
      case replyingToPost(_ publication: Model.Publication, _ of: String)
      case replyingToComment(_ publication: Model.Publication, _ of: String)
    }
    
    var navigationId: String
    var reason: Reason
    var publicationText: String = ""
    var isPosting: Bool = false
    var cancelAlert: AlertState<Action>?
    
    var photoPickerItem: PhotosPickerItem?
    var selectedPhoto: UIImage?
    var selectGif: GifController.State?
    var selectedGif: Cache.PublicationUploadRequest.Gif?
    
    var placeholder: String {
      switch self.reason {
        case .creatingPost:       return "Share your thoughts!"
        case .replyingToPost:     return "Share your reply!"
        case .replyingToComment:  return "Share your reply!"
      }
    }
  }
  
  enum Action: Equatable {
    case dismissView
    case publicationTextChanged(String)
    case didTapCancel
    case discardAndDismiss
    case cancelAlertDismissed
    case createPublication
    case createPublicationSuccess
    case createPublicationFailure
    
    case photoSelectionTapped(PhotosPickerItem?)
    case photoSelected(TaskResult<UIImage>)
    case deleteImageTapped
    case selectGifTapped
    case selectGif(GifController.Action)
    case setSelectGif(GifController.State?)
    case deleteGifTapped
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerOf<CreatePublication> {
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
            return .send(.discardAndDismiss)
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
          return .send(.dismissView)
          
        case .cancelAlertDismissed:
          state.cancelAlert = nil
          return .none
          
        case .createPublication:
          guard state.publicationText.trimmingCharacters(in: .whitespacesAndNewlines) != "",
              let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
          else { return .none }
          
          state.isPosting = true
          return .run { [reason = state.reason, publicationText = state.publicationText, selectedPhoto = state.selectedPhoto, selectedGif = state.selectedGif] send in
            
            let publicationType: Cache.PublicationUploadRequest.PublicationType
            switch reason {
              case .creatingPost:
                publicationType = .post
              case .replyingToPost(let publication, _), .replyingToComment(let publication, _):
                publicationType = .comment(parentPublication: publication)
            }
            var uploadMedia: [Cache.PublicationUploadRequest.UploadMedia] = []
            if let selectedPhoto { uploadMedia.append(.photo(selectedPhoto)) }
            if let selectedGif { uploadMedia.append(.gif(selectedGif)) }
            
            do {
              try await self.cache.createPublication(publicationType, publicationText, userProfile.id, userProfile.address, uploadMedia)
              await send(.createPublicationSuccess)
            }
            catch let error {
              log("Failed to create publication", level: .error, error: error)
              await send(.createPublicationFailure)
            }
            
          }
          
        case .createPublicationSuccess:
          state.publicationText = ""
          state.isPosting = false
          return .send(.dismissView)
          
        case .createPublicationFailure:
          state.isPosting = false
          return .none
          
        case .photoSelectionTapped(let item):
          state.photoPickerItem = item
          if let item {
            return .run { send in
              guard let data = try await item.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data)
              else {
                await send(.photoSelected(.failure(PHPhotosError(.invalidResource))))
                return
              }
              await send(.photoSelected(TaskResult { uiImage }))
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
              state.selectedGif = Cache.PublicationUploadRequest.Gif(previewURL: previewURL, displayURL: displayURL)
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
