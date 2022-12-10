// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI

struct LentilImage: ReducerProtocol {
  enum Kind: Equatable { case profile(_ handle: String), feed, cover }
  enum Resolution: Equatable { case display, storage }
  
  struct State: Equatable {
    enum StoredImage: Equatable {
      case notLoaded
      case image(Image)
      case notAvailable
    }
    
    let kind: Kind
    var imageUrl: URL
    fileprivate var storedImage: StoredImage
    fileprivate var cachedImage: Image? {
      if let medium = mediaCache[id: self.imageUrl.absoluteString],
         case .image = medium.mediaType,
         let imageData = mediaDataCache[id: self.imageUrl.absoluteString]?.data,
         let uiImage = imageData.image(for: self.kind, and: .display) {
        return Image(uiImage: uiImage)
      }
      else {
        return nil
      }
    }
    
    init(imageUrl: URL, kind: Kind) {
      self.imageUrl = imageUrl
      self.kind = kind
      self.storedImage = .notLoaded
      
      if let image = cachedImage {
        self.storedImage = .image(image)
      }
    }
  }
  
  enum Action: Equatable {
    case didAppear
    case updateImage(TaskResult<State.StoredImage>)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .didAppear:
        switch state.storedImage {
          case .notLoaded:
            if let image = state.cachedImage {
              state.storedImage = .image(image)
              return .none
            }
            else {
              return .task(
                priority: .userInitiated,
                operation: { [url = state.imageUrl, kind = state.kind] in
                  let data = try await lensApi.fetchImage(url)
                  if let storageData = data.imageData(for: kind, and: .storage),
                     let displayImage = data.image(for: kind, and: .display) {
                    mediaCache.updateOrAppend(Model.Media(mediaType: .image(.jpeg), url: url))
                    mediaDataCache.updateOrAppend(Model.MediaData(url: url.absoluteString, data: storageData))
                    return await .updateImage(TaskResult { .image(Image(uiImage: displayImage)) })
                  }
                  else {
                    return await .updateImage(TaskResult { .notAvailable })
                  }
                },
                catch: { error in
                  return .updateImage(.failure(error))
                }
              )
            }
          case .image, .notAvailable:
            return .none
        }

      case .updateImage(let .success(storedImage)):
        state.storedImage = storedImage
        return .none
        
      case .updateImage(.failure(let error)):
        state.storedImage = .notAvailable
        log("Failed to load remote image for \(String(describing: state.imageUrl.absoluteString))", level: .debug, error: error)
        return .none
    }
  }
}

struct LentilImageView: View {
  let store: Store<LentilImage.State, LentilImage.Action>
  
  var placeholder: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.kind {
        case .profile(let handle):
          profileGradient(from: handle)
          
        case .feed:
          ZStack {
            Theme.Color.greyShade1
            ProgressView()
          }
          
        case .cover:
          ZStack {
            lentilGradient()
            ProgressView()
          }
      }
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.storedImage {
        case .notLoaded:
          self.placeholder
            .onAppear { viewStore.send(.didAppear) }
          
        case .image(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
          
        case .notAvailable:
          if case .feed = viewStore.kind {
            EmptyView()
          }
          else {
            self.placeholder
          }
      }
    }
  }
}


#if DEBUG
struct LentilImageView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      LentilImageView(
        store: .init(
          initialState: LentilImage.State(imageUrl: URL(string: "https://profile-picture")!, kind: .profile("Cordt")),
          reducer: LentilImage()
        )
      )
      .frame(width: 40, height: 40)
      .clipShape(Circle())
      
      LentilImageView(
        store: .init(
          initialState: LentilImage.State(imageUrl: URL(string: "https://feed-picture")!, kind: .feed),
          reducer: LentilImage()
        )
      )
      .clipped()
      
      LentilImageView(
        store: .init(
          initialState: LentilImage.State(imageUrl: URL(string: "https://feed-picture-missing")!, kind: .feed),
          reducer: LentilImage()
        )
      )
      .clipped()
      
      LentilImageView(
        store: .init(
          initialState: LentilImage.State(imageUrl: URL(string: "https://cover-picture")!, kind: .cover),
          reducer: LentilImage()
        )
      )
      
    }
  }
}
#endif
