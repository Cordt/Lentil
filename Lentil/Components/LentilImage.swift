// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI

struct LentilImage: ReducerProtocol {
  enum Kind: Equatable { case profile(_ handle: String), feed, cover }
  enum Resolution: Equatable { case display, storage }
  
  struct State: Equatable, Identifiable {
    enum StoredImage: Equatable {
      case notLoaded
      case image(Image)
      case notAvailable
    }
    var id: String { self.imageUrl.absoluteString }
    
    let kind: Kind
    var imageUrl: URL
    fileprivate var storedImage: StoredImage
    var imageView: Image?
    
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
    case imageDetailTapped
    case updateImageDetail(Image?)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.lensApi) var lensApi
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didAppear:
          return .none
          
        case .didAppearFinishing:
          switch state.storedImage {
            case .notLoaded:
              return .task(priority: .userInitiated) { [imageUrl = state.imageUrl, kind = state.kind] in
                if let medium = self.cache.medium(imageUrl.absoluteString),
                   case .image = medium.mediaType,
                   let imageData = self.cache.mediumData(imageUrl.absoluteString)?.data,
                   let uiImage = imageData.image(for: kind, and: .display) {
                  
                  return await .updateImage(TaskResult { .image(Image(uiImage: uiImage)) })
                }
                else {
                  let data = try await lensApi.fetchImage(imageUrl)
                  if let storageData = data.imageData(for: kind, and: .storage),
                     let displayImage = data.image(for: kind, and: .display) {
                    self.cache.updateOrAppendMedia(Model.Media(mediaType: .image(.jpeg), url: imageUrl))
                    self.cache.updateOrAppendMediaData(Model.MediaData(url: imageUrl.absoluteString, data: storageData))
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
          
        case .imageDetailTapped:
          guard case .image(let image) = state.storedImage
          else { return .none }
          state.imageView = image
          return .none
          
        case .updateImageDetail(let image):
          state.imageView = image
          return .none
      }
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
          if (viewStore.kind == .feed || viewStore.kind == .cover) {
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .onTapGesture { viewStore.send(.imageDetailTapped) }
              .navigationDestination(
                unwrapping: viewStore.binding(
                  get: \.imageView,
                  send: LentilImage.Action.imageDetailTapped
                )) { image in
                  ImageView(
                    image: image.wrappedValue,
                    dismiss: { viewStore.send(.updateImageDetail(nil)) }
                  )
                }
          }
          else {
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          }
          
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
    NavigationStack {
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
}
#endif
