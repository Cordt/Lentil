// Lentil

import ComposableArchitecture
import CoreImage
import SwiftUI

extension View {
  func punkRaffle(store: Store<PunkRaffleState, PunkRaffleAction>) -> some View {
    self.modifier(PunkRaffle(store: store))
  }
}

struct PunkRaffle: ViewModifier {
  let store: Store<PunkRaffleState, PunkRaffleAction>
  
  func body(content: Content) -> some View {
    WithViewStore(self.store) { viewStore in
      content
        .popup(
          isPresented: viewStore.binding(
            get: { $0.popupIsPresented },
            send: PunkRaffleAction.togglePopup
          )
        ) {
          ZStack {
            VStack {
              viewStore.image?
                .resizable()
                .frame(width: 100, height: 100)
                .offset(y: viewStore.punkYOffset)
                .opacity(viewStore.punkOpacity)
              
              Spacer()
            }
            
            VStack {
              VStack {
                Text("Your keys, your profile")
                  .font(.title3)
                  .fontWeight(.medium)
                  .padding()
                
                Text("Log in with your wallet\nto see this section")
                  .font(.body)
                  .padding([.leading, .trailing, .bottom], 16)
              }
              .multilineTextAlignment(.center)
              .fixedSize()
              
              Button("Setup Wallet") {
                // TODO Send to settings
              }
              .buttonStyle(.borderedProminent)
              .tint(ThemeColor.primaryRed.color)
              .padding()
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(ThemeColor.faintGray.color)
            )
          }
        }
    }
  }
}


struct PunkRaffle_Previews: PreviewProvider {
  static let store = Store<PunkRaffleState, PunkRaffleAction>(
    initialState: .init(),
    reducer: punkRaffleReducer,
    environment: ()
  )
  
  static var previews: some View {
    WithViewStore(Self.store) { viewStore in
      Button("Show me") {
        viewStore.send(.togglePopup(isPresented: true))
      }
      .punkRaffle(store: Self.store)
    }
  }
}



struct PunkRaffleState: Equatable {
  let images: [UIImage] = slice(image: UIImage(named: "punks")!, into: 100)
  var image: Image?
  var popupIsPresented: Bool = false
  var punkOpacity: CGFloat = 0
  var punkYOffset: CGFloat = 0
}

enum PunkRaffleAction: Equatable {
  case togglePopup(isPresented: Bool)
  case setPresentation(isPresented: Bool)
  case setOpacity(isPresented: Bool)
  case setOffset(isPresented: Bool)
  case dismiss
}

let punkRaffleReducer: Reducer<PunkRaffleState, PunkRaffleAction, Void> = Reducer { state, action, _ in
  enum ImageLoaderID {}
  
  switch action {
    case .togglePopup(let isPresented):
      if isPresented {
        guard let image = state.images.randomElement()
        else { return .none }
        
        state.image = Image(uiImage: image)
      }
      
      return .run(priority: .userInitiated) { send in
        if isPresented {
          try await Task.sleep(nanoseconds: NSEC_PER_SEC)
          await send(.setPresentation(isPresented: isPresented))
          await send(.setOpacity(isPresented: isPresented))
          try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
          await send(.setOffset(isPresented: isPresented), animation: .easeOut(duration: 0.25))
        }
        else {
          await send(.setOffset(isPresented: isPresented), animation: .easeIn(duration: 0.25))
          try await Task.sleep(nanoseconds: NSEC_PER_SEC / 2)
          await send(.setOpacity(isPresented: isPresented))
          await send(.setPresentation(isPresented: isPresented))
        }
      }
      
    case .setPresentation(let isPresented):
      state.popupIsPresented = isPresented
      return .none
      
    case .setOpacity(let isPresented):
      state.punkOpacity = isPresented ? 1.0 : 0
      return .none
      
    case .setOffset(let isPresented):
      state.punkYOffset = isPresented ? -100 : 0
      return .none
      
    case .dismiss:
      state.popupIsPresented = false
      state.punkOpacity = 0
      state.punkYOffset = 0
      return .none
  }
}


func slice(image: UIImage, into howMany: Int) -> [UIImage] {
  let width: CGFloat
  let height: CGFloat
  
  switch image.imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      width = image.size.height
      height = image.size.width
    default:
      width = image.size.width
      height = image.size.height
  }
  
  let tileWidth = Int(width / CGFloat(howMany))
  let tileHeight = Int(height / CGFloat(howMany))
  
  let scale = Int(image.scale)
  var images = [UIImage]()
  
  let cgImage = image.cgImage!
  
  var adjustedHeight = tileHeight
  
  var y = 0
  for row in 0 ..< howMany {
    if row == (howMany - 1) {
      adjustedHeight = Int(height) - y
    }
    var adjustedWidth = tileWidth
    var x = 0
    for column in 0 ..< howMany {
      if column == (howMany - 1) {
        adjustedWidth = Int(width) - x
      }
      let origin = CGPoint(x: x * scale, y: y * scale)
      let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
      let tileCgImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
      images.append(UIImage(cgImage: tileCgImage, scale: image.scale, orientation: image.imageOrientation))
      x += tileWidth
    }
    y += tileHeight
  }
  return images
}
