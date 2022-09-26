// Lentil

import ComposableArchitecture
import SwiftUI

struct TimelineState: Equatable {
  var images: [UIImage]
  var image: Image?
}

enum TimelineAction: Equatable {
  case loadImage
  case cancelImageShuffling
  case updateImage(Image?)
}

let timelineReducer: Reducer<TimelineState, TimelineAction, RootEnvironment> = Reducer { state, action, env in
  
  enum ImageLoaderID {}
  
  switch action {
    case .loadImage:
      return .run(priority: .userInitiated) { [images = state.images] send in
        guard !Task.isCancelled else { return }
        
        for try await step in EasedDelay() {
          if let image = images.randomElement(),
             let jittered = jitter(in: image, strength: CGFloat(step) / 100.0, damping: CGFloat(step) / 250.0) {
            
            await send(.updateImage(Image(uiImage: jittered)))
          }
        }
        
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        await send(.loadImage)
      }
      .cancellable(id: ImageLoaderID.self, cancelInFlight: true)
      
    case .cancelImageShuffling:
      return .cancel(id: ImageLoaderID.self)
      
    case .updateImage(let image):
      state.image = image
      return .none
  }
}
