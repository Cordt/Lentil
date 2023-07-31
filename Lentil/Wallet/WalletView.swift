// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct WalletView: View {
  @Environment(\.dismiss) var dismiss
  let store: Store<WalletConnection.State, WalletConnection.Action>
  
  func step(state: WalletConnection.ConnectionState) -> String {
    switch state {
      case .notConnected, .waitingForConnection:  return "1/3"
      case .connected, .waitingForSignature:      return "2/3"
      case .authenticated:                        return "3/3"
    }
  }
  
  func title(state: WalletConnection.ConnectionState) -> String {
    switch state {
      case .notConnected, .waitingForConnection:  return "Connect your Wallet"
      case .connected, .waitingForSignature:      return "Sign in"
      case .authenticated:                        return "Success!"
    }
  }
  
  func body(state: WalletConnection.ConnectionState) -> String {
    switch state {
      case .notConnected, .waitingForConnection:
        return "You need to connect your wallet and Lens handle to Lentil in order to interact with content on Lentil.\n\nDon't have access to Lens yet? Reach out to them to get yourself a Lens handle!"
      case .connected, .waitingForSignature:
        return "Sign in with Lens to interact with content on Lentil.\n\nDon’t have access to Lens yet? Reach out to them to get yourself a Lens handle!"
      case .authenticated:
        return "You are now logged in and can start interacting.\n\nHave fun!"
    }
  }
  
  func button(title: String, action: @escaping () -> Void, disabled: Bool) -> some View {
    LentilButton(title: title, disabled: disabled, action: action)
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        Rectangle()
          .fill(Theme.lentilGradient())
          .ignoresSafeArea()
        
        VStack(spacing: 20) {
          Text(step(state: viewStore.connectionStatus))
            .font(style: .bodyDetailed, color: Theme.Color.white)
          
          VStack(spacing: 20) {
            Text(title(state: viewStore.connectionStatus))
              .font(style: .largeHeadline)
            
            Text(body(state: viewStore.connectionStatus))
              .font(style: .bodyDetailed)
          }
          .multilineTextAlignment(.center)
          .padding(30)
          .background {
            RoundedRectangle(cornerRadius: 5)
              .fill(Theme.Color.white)
          }
          .padding([.leading, .trailing], 30)
          
          switch viewStore.connectionStatus {
            case .notConnected:
              self.button(title: "Connect now", action: { viewStore.send(.connectTapped) }, disabled: false)
            case .waitingForConnection:
              self.button(title: "Connect now", action: { viewStore.send(.connectTapped) }, disabled: true)
            case .connected:
              self.button(title: "Sign in with Lens", action: { viewStore.send(.signInTapped) }, disabled: false)
            case .waitingForSignature:
              self.button(title: "Sign in with Lens", action: { viewStore.send(.signInTapped) }, disabled: true)
            case .authenticated:
              self.button(title: "Let's go!", action: { self.dismiss() }, disabled: false)
          }
        }
        .offset(y: -50)
      }
      .toastView(
        toast: viewStore.binding(
          get: \.errorMessage,
          send: { WalletConnection.Action.errorMessageUpdated($0) }
        )
      )
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            self.dismiss()
          } label: {
            Icon.back.view(.xlarge)
              .foregroundColor(Theme.Color.white)
          }
        }
        ToolbarItem(placement: .principal) {
          Text("lentil")
            .font(highlight: .largeHeadline, color: Theme.Color.white)
        }
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .toolbar(.hidden, for: .tabBar)
      .navigationBarBackButtonHidden(true)
      .accentColor(Theme.Color.primary)
      .onDisappear {
        viewStore.send(.walletClosed)
      }
    }
  }
}


struct WalletConnectView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      WalletView(
        store: .init(
          initialState: WalletConnection.State(connectionStatus: .notConnected),
          reducer: { WalletConnection() }
        )
      )
    }
  }
}
