// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct MultiImage: ReducerProtocol {
  struct State: Equatable {
    var images: IdentifiedArrayOf<LentilImage.State>
  }
  
  enum Action: Equatable {
    case imageTapped(LentilImage.State.ID)
    case image(LentilImage.State.ID, LentilImage.Action)
  }
  
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .imageTapped(let id):
          guard let imageState = state.images[id: id]
          else { return .none}
          
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .imageDetail(imageState.imageUrl)
            )
          )
          return .none
          
        case .image:
          return .none
      }
    }
    .forEach(\.images, action: /Action.image) {
      LentilImage()
    }
  }
}

struct MultiImageView: View {
  let store: Store<MultiImage.State, MultiImage.Action>
    
  @ViewBuilder
  func image(
    imageId: String,
    statePath: @escaping (MultiImage.State) -> LentilImage.State,
    actionPath: @escaping (LentilImage.Action) -> MultiImage.Action,
    dimensions: CGSize
  ) -> some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      LentilImageView(
        store: self.store.scope(
          state: statePath,
          action: actionPath
        )
      )
      .frame(width: dimensions.width, height: dimensions.height)
      .clipped()
      .contentShape(Rectangle().inset(by: 20))
      .onTapGesture { viewStore.send(.imageTapped(imageId)) }
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.images.count {
        case 1:
          GeometryReader { geometry in
            self.image(
              imageId: viewStore.images[0].id,
              statePath: \.images[0],
              actionPath: { MultiImage.Action.image(viewStore.images[0].id, $0) },
              dimensions: geometry.size
            )
          }
        case 2:
          GeometryReader { geometry in
            HStack {
              self.image(
                imageId: viewStore.images[0].id,
                statePath: \.images[0],
                actionPath: { MultiImage.Action.image(viewStore.images[0].id, $0) },
                dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height)
              )
              
              self.image(
                imageId: viewStore.images[1].id,
                statePath: \.images[1],
                actionPath: { MultiImage.Action.image(viewStore.images[1].id, $0) },
                dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height)
              )
            }
          }
        case 3:
          GeometryReader { geometry in
            VStack {
              HStack {
                self.image(
                  imageId: viewStore.images[0].id,
                  statePath: \.images[0],
                  actionPath: { MultiImage.Action.image(viewStore.images[0].id, $0) },
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 3.0)
                )
                
                self.image(
                  imageId: viewStore.images[1].id,
                  statePath: \.images[1],
                  actionPath: { MultiImage.Action.image(viewStore.images[1].id, $0) },
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 3.0)
                )
              }
              
              self.image(
                imageId: viewStore.images[2].id,
                statePath: \.images[2],
                actionPath: { MultiImage.Action.image(viewStore.images[2].id, $0) },
                dimensions: CGSize(width: geometry.size.width, height: geometry.size.height / 3.0 * 2.0)
              )
            }
          }
        case 4:
          GeometryReader { geometry in
            VStack {
              HStack {
                self.image(
                  imageId: viewStore.images[0].id,
                  statePath: \.images[0],
                  actionPath: { MultiImage.Action.image(viewStore.images[0].id, $0) },
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 2.0)
                )
                
                self.image(
                  imageId: viewStore.images[1].id,
                  statePath: \.images[1],
                  actionPath: { MultiImage.Action.image(viewStore.images[1].id, $0) },
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 2.0)
                )
              }
              HStack {
                self.image(
                  imageId: viewStore.images[2].id,
                  statePath: \.images[2],
                  actionPath: { MultiImage.Action.image(viewStore.images[2].id, $0) },
                  dimensions: CGSize(width: max(geometry.size.width * 0.5 - 4, 0) , height: geometry.size.height / 2.0)
                )
                
                self.image(
                  imageId: viewStore.images[3].id,
                  statePath: \.images[3],
                  actionPath: { MultiImage.Action.image(viewStore.images[3].id, $0) },
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
