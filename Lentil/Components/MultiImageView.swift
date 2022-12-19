// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct MultiImage: ReducerProtocol {
  struct State: Equatable {
    var images: IdentifiedArrayOf<LentilImage.State>
  }
  
  enum Action: Equatable {
    case image(LentilImage.State.ID, LentilImage.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
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
    
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.images.count {
        case 1:
          GeometryReader { geometry in
            LentilImageView(
              store: self.store.scope(
                state: \.images[0],
                action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
              )
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
          }
        case 2:
          GeometryReader { geometry in
            HStack {
              LentilImageView(
                store: self.store.scope(
                  state: \.images[0],
                  action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
                )
              )
              .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height)
              .clipped()
              
              LentilImageView(
                store: self.store.scope(
                  state: \.images[1],
                  action: { MultiImage.Action.image(viewStore.images[1].id, $0) }
                )
              )
              .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height)
              .clipped()
            }
          }
        case 3:
          GeometryReader { geometry in
            VStack {
              HStack {
                LentilImageView(
                  store: self.store.scope(
                    state: \.images[0],
                    action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
                  )
                )
                .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height / 3)
                .clipped()
                
                LentilImageView(
                  store: self.store.scope(
                    state: \.images[1],
                    action: { MultiImage.Action.image(viewStore.images[1].id, $0) }
                  )
                )
                .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height / 3)
                .clipped()
              }
              
              LentilImageView(
                store: self.store.scope(
                  state: \.images[2],
                  action: { MultiImage.Action.image(viewStore.images[2].id, $0) }
                )
              )
              .frame(width: geometry.size.width, height: geometry.size.height / 3 * 2)
              .clipped()
            }
          }
        case 4:
          GeometryReader { geometry in
            VStack {
              HStack {
                LentilImageView(
                  store: self.store.scope(
                    state: \.images[0],
                    action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
                  )
                )
                .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height / 2)
                .clipped()
                
                LentilImageView(
                  store: self.store.scope(
                    state: \.images[1],
                    action: { MultiImage.Action.image(viewStore.images[1].id, $0) }
                  )
                )
                .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height / 2)
                .clipped()
              }
              HStack {
                LentilImageView(
                  store: self.store.scope(
                    state: \.images[2],
                    action: { MultiImage.Action.image(viewStore.images[2].id, $0) }
                  )
                )
                .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height / 2)
                .clipped()
                
                LentilImageView(
                  store: self.store.scope(
                    state: \.images[3],
                    action: { MultiImage.Action.image(viewStore.images[3].id, $0) }
                  )
                )
                .frame(width: geometry.size.width * 0.5 - 4, height: geometry.size.height / 2)
                .clipped()
              }
            }
          }
        default:
          EmptyView()
      }
    }
  }
}
