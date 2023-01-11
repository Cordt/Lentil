// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SDWebImageSwiftUI
import SwiftUI


struct MultiImage: ReducerProtocol {
  struct LentilImage: Equatable, Identifiable {
    var id: Int
    var url: URL
  }
  
  struct State: Equatable {
    var images: IdentifiedArrayOf<LentilImage>
  }
  
  enum Action: Equatable {
    case imageTapped(LentilImage.ID)
  }
  
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .imageTapped(let id):
          guard let image = state.images[id: id]
          else { return .none}
          
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .imageDetail(image.url)
            )
          )
          return .none
      }
    }
  }
}

struct MultiImageView: View {
  let store: Store<MultiImage.State, MultiImage.Action>
    
  @ViewBuilder
  func image(
    imageID: Int,
    dimensions: CGSize
  ) -> some View {
    WithViewStore(self.store, observe: { $0.images[imageID] }) { viewStore in
      WebImage(url: viewStore.url)
        .resizable()
        .placeholder {
          Rectangle()
            .foregroundColor(Theme.Color.greyShade1)
        }
        .indicator(.activity)
        .transition(.fade(duration: 0.5))
        .scaledToFill()
        .frame(width: dimensions.width, height: dimensions.height)
        .clipped()
        .contentShape(Rectangle().inset(by: 20))
        .onTapGesture { viewStore.send(.imageTapped(viewStore.id)) }
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.images.count {
        case 1:
          GeometryReader { geometry in
            self.image(
              imageID: 0,
              dimensions: geometry.size
            )
          }
        case 2:
          GeometryReader { geometry in
            HStack {
              self.image(
                imageID: 0,
                dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height)
              )
              
              self.image(
                imageID: 1,
                dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height)
              )
            }
          }
        case 3:
          GeometryReader { geometry in
            VStack {
              HStack {
                self.image(
                  imageID: 0,
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 3.0)
                )
                
                self.image(
                  imageID: 1,
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 3.0)
                )
              }
              
              self.image(
                imageID: 2,
                dimensions: CGSize(width: geometry.size.width, height: geometry.size.height / 3.0 * 2.0)
              )
            }
          }
        case 4:
          GeometryReader { geometry in
            VStack {
              HStack {
                self.image(
                  imageID: 0,
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 2.0)
                )
                
                self.image(
                  imageID: 1,
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 2.0)
                )
              }
              HStack {
                self.image(
                  imageID: 2,
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 2.0)
                )
                
                self.image(
                  imageID: 3,
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 2.0)
                )
              }
            }
          }
        default:
          EmptyView()
      }
    }
  }
}

#if DEBUG
struct MultiImageView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      VStack {
        MultiImageView(
          store: .init(
            initialState: .init(
              images: [
                MultiImage.LentilImage(id: 0, url: URL(string: "https://feed-picture")!),
                MultiImage.LentilImage(id: 1, url: URL(string: "https://cover-picture")!),
                MultiImage.LentilImage(id: 2, url: URL(string: "https://crete")!)
              ]
            ),
            reducer: MultiImage()
          )
        )
      }
    }
  }
}
#endif
