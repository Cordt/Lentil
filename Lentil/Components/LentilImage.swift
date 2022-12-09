// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI

struct LentilImage: ReducerProtocol {
  enum Kind: Equatable { case profile, feed, cover }
  enum Resolution: Equatable { case display, storage }
  
  struct State: Equatable {
    enum StoredImage: Equatable {
      case notLoaded
      case image(Image)
      case notAvailable
    }
    
    let kind: Kind
    var imageUrl: URL?
    fileprivate var storedImage: StoredImage
    fileprivate var cachedImage: Image? {
      if let imageUrl = self.imageUrl,
         let medium = mediaCache[id: imageUrl.absoluteString],
         case .image = medium.mediaType,
         let imageData = mediaDataCache[id: imageUrl.absoluteString]?.data,
         let uiImage = imageData.image(for: self.kind, and: .display) {
        return Image(uiImage: uiImage)
      }
      else {
        return nil
      }
    }
    var image: Image? {
      guard case .image(let loadedImage) = self.storedImage
      else { return nil }
      return loadedImage
    }
    
    init(imageUrl: URL? = nil, kind: Kind) {
      self.imageUrl = imageUrl
      self.kind = kind
      self.storedImage = .notLoaded
      
      if let image = cachedImage {
        self.storedImage = .image(image)
      }
    }
  }
  
  enum Action: Equatable {
    case fetchImage
    case updateImage(TaskResult<State.StoredImage>)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .fetchImage:
        switch state.storedImage {
          case .notLoaded:
            if let image = state.cachedImage {
              state.storedImage = .image(image)
              return .none
            }
            else if let url = state.imageUrl {
              return .task(priority: .userInitiated) { [url, kind = state.kind] in
                let data = try await lensApi.fetchImage(url)
                if
                  let storageData = data.imageData(for: kind, and: .storage),
                  let displayImage = data.image(for: kind, and: .display)
                {
                  mediaCache.updateOrAppend(Model.Media(mediaType: .image(.jpeg), url: url))
                  mediaDataCache.updateOrAppend(Model.MediaData(url: url.absoluteString, data: storageData))
                  return await .updateImage(TaskResult { .image(Image(uiImage: displayImage)) })
                }
                else {
                  return await .updateImage(TaskResult { .notAvailable })
                }
              }
            }
            else {
              return .none
            }
          case .image, .notAvailable:
            return .none
        }

      case .updateImage(let .success(storedImage)):
        state.storedImage = storedImage
        return .none
        
      case .updateImage(.failure(let error)):
        state.storedImage = .notAvailable
        log("Failed to load remote image for \(String(describing: state.imageUrl?.absoluteString))", level: .debug, error: error)
        return .none
    }
  }
}
