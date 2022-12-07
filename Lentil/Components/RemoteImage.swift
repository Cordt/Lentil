// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI

struct RemoteImage: ReducerProtocol {
  struct State: Equatable {
    enum StoredImage: Equatable {
      case notLoaded
      case image(Image)
      case notAvailable
    }
    
    var imageUrl: URL?
    fileprivate var storedImage: StoredImage
    fileprivate var cachedImage: Image? {
      if let imageUrl = self.imageUrl,
         let medium = mediaCache[id: imageUrl.absoluteString],
         case .image = medium.mediaType,
         let imageData = mediaDataCache[id: imageUrl.absoluteString]?.data,
         let uiImage = UIImage(data: imageData) {
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
    
    init(imageUrl: URL? = nil) {
      self.imageUrl = imageUrl
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
              return .task(priority: .userInitiated) { [url] in
                let imageData = try await lensApi.fetchImage(url)

                if let uiImage = UIImage(data: imageData)?.compressed()?.aspectFittedToDimension(800) {
                  mediaDataCache.updateOrAppend(Model.MediaData(url: url.absoluteString, data: imageData))
                  return await .updateImage(TaskResult { .image(Image(uiImage: uiImage)) })
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
