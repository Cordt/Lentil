// Lentil

import ComposableArchitecture
import SwiftUI

struct TimelineView: View {
  let store: Store<TimelineState, TimelineAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Spacer()
        
        VStack {
          Text("We value your privacy, Anon.")
            .font(.headline)
          
          Text("But you need to be logged in with your wallet to see this section")
            .font(.body)
        }
        .multilineTextAlignment(.center)
        .padding()
        
        Button("Setup Wallet") {
          // TODO Send to settings
        }
        .buttonStyle(.borderedProminent)
        .tint(ThemeColor.primaryRed.color)
        
        Spacer()
        
        viewStore.image?
          .resizable()
          .frame(width: 150, height: 150)
      }
      .frame(width: 300)
      .task { viewStore.send(.loadImage) }
      .onDisappear { viewStore.send(.cancelImageShuffling) }
    }
  }
}


struct TimelineView_Previews: PreviewProvider {
  static var previews: some View {
    TimelineView(
      store: .init(
        initialState: .init(images: LentilApp.punkImages),
        reducer: timelineReducer,
        environment: .mock
      )
    )
  }
}
