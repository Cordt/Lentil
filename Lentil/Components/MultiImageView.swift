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
          LentilImageView(
            store: self.store.scope(
              state: \.images[0],
              action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
            )
          )
        case 2:
          HStack {
            LentilImageView(
              store: self.store.scope(
                state: \.images[0],
                action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
              )
            )
            LentilImageView(
              store: self.store.scope(
                state: \.images[1],
                action: { MultiImage.Action.image(viewStore.images[1].id, $0) }
              )
            )
          }
        case 3:
          VStack {
            HStack {
              LentilImageView(
                store: self.store.scope(
                  state: \.images[0],
                  action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
                )
              )
              LentilImageView(
                store: self.store.scope(
                  state: \.images[1],
                  action: { MultiImage.Action.image(viewStore.images[1].id, $0) }
                )
              )
            }
            LentilImageView(
              store: self.store.scope(
                state: \.images[2],
                action: { MultiImage.Action.image(viewStore.images[2].id, $0) }
              )
            )
          }
        case 4:
          VStack {
            HStack {
              LentilImageView(
                store: self.store.scope(
                  state: \.images[0],
                  action: { MultiImage.Action.image(viewStore.images[0].id, $0) }
                )
              )
              LentilImageView(
                store: self.store.scope(
                  state: \.images[1],
                  action: { MultiImage.Action.image(viewStore.images[1].id, $0) }
                )
              )
            }
            HStack {
              LentilImageView(
                store: self.store.scope(
                  state: \.images[2],
                  action: { MultiImage.Action.image(viewStore.images[2].id, $0) }
                )
              )
              LentilImageView(
                store: self.store.scope(
                  state: \.images[3],
                  action: { MultiImage.Action.image(viewStore.images[3].id, $0) }
                )
              )
            }
          }
        default:
          EmptyView()
      }
    }
  }
}
