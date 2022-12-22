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
    dimensions: @escaping (CGSize) -> CGSize
  ) -> some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      GeometryReader { geometry in
        LentilImageView(
          store: self.store.scope(
            state: statePath,
            action: actionPath
          )
        )
        .frame(width: dimensions(geometry.size).width, height: dimensions(geometry.size).height)
        .clipped()
        .contentShape(Rectangle().inset(by: 20))
        .onTapGesture { viewStore.send(.imageTapped(imageId)) }
      }
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.images.count {
        case 1:
          self.image(
            imageId: viewStore.images[0].id,
            statePath: \.images[0],
            actionPath: { MultiImage.Action.image(viewStore.images[0].id, $0) },
            dimensions: { $0 }
          )
        case 2:
          GeometryReader { geometry in
            HStack {
              self.image(
                imageId: viewStore.images[0].id,
                statePath: \.images[0],
                actionPath: { MultiImage.Action.image(viewStore.images[0].id, $0) },
                dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height) }
              )
              
              self.image(
                imageId: viewStore.images[1].id,
                statePath: \.images[1],
                actionPath: { MultiImage.Action.image(viewStore.images[1].id, $0) },
                dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height) }
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
                  dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height / 3.0) }
                )
                
                self.image(
                  imageId: viewStore.images[1].id,
                  statePath: \.images[1],
                  actionPath: { MultiImage.Action.image(viewStore.images[1].id, $0) },
                  dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height / 3.0) }
                )
              }
              
              self.image(
                imageId: viewStore.images[2].id,
                statePath: \.images[2],
                actionPath: { MultiImage.Action.image(viewStore.images[2].id, $0) },
                dimensions: { CGSize(width: $0.width, height: $0.height / 3.0 * 2.0) }
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
                  dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height / 2.0) }
                )
                
                self.image(
                  imageId: viewStore.images[1].id,
                  statePath: \.images[1],
                  actionPath: { MultiImage.Action.image(viewStore.images[1].id, $0) },
                  dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height / 2.0) }
                )
              }
              HStack {
                self.image(
                  imageId: viewStore.images[2].id,
                  statePath: \.images[2],
                  actionPath: { MultiImage.Action.image(viewStore.images[2].id, $0) },
                  dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height / 2.0) }
                )
                
                self.image(
                  imageId: viewStore.images[3].id,
                  statePath: \.images[3],
                  actionPath: { MultiImage.Action.image(viewStore.images[3].id, $0) },
                  dimensions: { CGSize(width: max($0.width * 0.5 - 4, 0) , height: $0.height / 2.0) }
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
