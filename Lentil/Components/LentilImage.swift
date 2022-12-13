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
    
    init(imageUrl: URL, kind: Kind) {
      self.imageUrl = imageUrl
      self.kind = kind
      self.storedImage = .notLoaded
    }
  }
  
  enum Action: Equatable {
    case didAppear
    case didAppearFinishing
    case updateImage(TaskResult<State.StoredImage>)
  }
  
  @Dependency(\.lensApi) var lensApi
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .didAppear:
        return .none
        
      case .didAppearFinishing:
        switch state.storedImage {
          case .notLoaded:
            return .task(priority: .background) { [imageUrl = state.imageUrl, kind = state.kind] in
              if let medium = Cache.shared.medium(imageUrl.absoluteString),
                 case .image = medium.mediaType,
                 let imageData = Cache.shared.mediumData(imageUrl.absoluteString)?.data,
                 let uiImage = imageData.image(for: kind, and: .display) {
                
                return await .updateImage(TaskResult { .image(Image(uiImage: uiImage)) })
              }
              else {
                let data = try await lensApi.fetchImage(imageUrl)
                if let storageData = data.imageData(for: kind, and: .storage),
                   let displayImage = data.image(for: kind, and: .display) {
                  Cache.shared.updateOrAppend(Model.Media(mediaType: .image(.jpeg), url: imageUrl))
                  Cache.shared.updateOrAppend(Model.MediaData(url: imageUrl.absoluteString, data: storageData))
                  return await .updateImage(TaskResult { .image(Image(uiImage: displayImage)) })
                }
                else {
                  return await .updateImage(TaskResult { .notAvailable })
                }
              }
            }
            catch: { error in
              return .updateImage(.failure(error))
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
            .task {
              await viewStore.send(.didAppearFinishing)
                .finish()
            }
          
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
