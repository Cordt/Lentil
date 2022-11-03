// Lentil

import ComposableArchitecture
import SwiftUI


struct SettingsView: View {
  let store: Store<Settings.State, Settings.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Text("WalletConnect")
        Button("Open Wallet") {
          viewStore.send(.openWallet)
        }
      }
        .onAppear {
          viewStore.send(.didAppear)
        }
    }
  }
}


struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(
      store: .init(
        initialState: .init(),
        reducer: Settings()
      )
    )
  }
}
