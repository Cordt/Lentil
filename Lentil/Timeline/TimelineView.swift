// Lentil

import ComposableArchitecture
import SwiftUI

struct TimelineView: View {
  let store: Store<TimelineState, TimelineAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Text("Soon™")
        .punkRaffle(
          store: self.store.scope(
            state: \.punkState,
            action: TimelineAction.punkAction
          )
        )
        .onAppear { viewStore.send(.punkAction(.togglePopup(isPresented: true))) }
        .onDisappear { viewStore.send(.punkAction(.dismiss)) }
    }
  }
}


struct TimelineView_Previews: PreviewProvider {
  static var previews: some View {
    TimelineView(
      store: .init(
        initialState: .init(),
        reducer: timelineReducer,
        environment: .mock
      )
    )
  }
}
