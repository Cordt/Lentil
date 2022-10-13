// Lentil

import ComposableArchitecture
import GenericJSON
import SwiftUI
import web3

struct SignTransaction: ReducerProtocol {
  struct State: Equatable {
    var sheetIsPresented: Bool = false
    var typedDataResult: TypedDataResult
  }
  
  enum Action: Equatable {
    case setSheetPresented(Bool)
    case rejectTransaction
    case signTransaction
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .setSheetPresented(let present):
        state.sheetIsPresented = present
        return .none
        
      case .rejectTransaction, .signTransaction:
        // Handled by parent reducer
        return .none
    }
  }
}


extension View {
  func signTransactionSheet(store: Store<SignTransaction.State?, SignTransaction.Action>) -> some View {
    IfLetStore(
      store,
      then: { self.modifier(SignTransactionViewModifier(store: $0)) },
      else: { self }
    )
  }
}

struct SignTransactionViewModifier: ViewModifier {
  let store: Store<SignTransaction.State, SignTransaction.Action>
  
  func body(content: Content) -> some View {
    WithViewStore(self.store) { viewStore in
      content
        .sheet(
          isPresented: viewStore.binding(
            get: { $0.sheetIsPresented },
            send: SignTransaction.Action.setSheetPresented
          ),
          content: {
            SignTransactionView(store: self.store)
          }
        )
    }
  }
}

struct SignTransactionView: View {
  let store: Store<SignTransaction.State, SignTransaction.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Rectangle()
          .fill(ThemeColor.faintGray.color)
          .frame(height: 50)
          .overlay {
            HStack {
              Text("Signature request")
                .font(.headline)
              
              Spacer()
              
              Button {
                viewStore.send(.setSheetPresented(false))
              } label: {
                Image(systemName: "multiply")
                  .foregroundColor(ThemeColor.lightGrey.color)
              }
              
            }
            .padding()
          }
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Requested by")
            .font(.subheadline)
            .fontWeight(.medium)
            
          Divider()
            .padding(.top, 8)
            .padding(.bottom, 16)
          
          VStack(alignment: .leading) {
            dataFieldView(title: "Name", from: viewStore.typedDataResult.typedData.domain, id: "name")
            dataFieldView(title: "Chain ID", from: viewStore.typedDataResult.typedData.domain, id: "chainId")
            dataFieldView(title: "Version", from: viewStore.typedDataResult.typedData.domain, id: "version")
            dataFieldView(title: "Contract", from: viewStore.typedDataResult.typedData.domain, id: "verifyingContract")
          }
          .padding(.bottom, 32)
          
          Text("Message")
            .font(.subheadline)
            .fontWeight(.medium)
          
          Divider()
            .padding(.top, 8)
            .padding(.bottom, 16)
          
          VStack(alignment: .leading) {
            dataFieldView(title: "Profile ID", from: viewStore.typedDataResult.typedData.message, id: "profileId")
            dataFieldView(title: "Nonce", from: viewStore.typedDataResult.typedData.message, id: "nonce")
            dataFieldView(title: "Deadline", from: viewStore.typedDataResult.typedData.message, id: "deadline")
            dataFieldView(title: "Wallet", from: viewStore.typedDataResult.typedData.message, id: "wallet")
          }
        }
        .padding()
        
        VStack {
          HStack {
            Button("Reject transaction") {
              viewStore.send(.rejectTransaction)
            }
            Button("Sign transaction") {
              viewStore.send(.signTransaction)
            }
          }
          .buttonStyle(.borderedProminent)
          .tint(ThemeColor.primaryRed.color)
          .padding()
        }
        .padding()
        
        Spacer()
      }
    }
  }
  
  @ViewBuilder
  func dataFieldView(title: String, from: JSON, id: String) -> some View {
    if let field = from[id]?.stringValue {
      let prefix = title.count < 8 ? "\t" : ""
      if field.prefix(2) == "0x" && field.count == 42,
         let explorerUrl = ProcessInfo.processInfo.environment["BLOCK_EXPLORER_URL"],
         let url = URL(string: explorerUrl + field) {
        let addressShortened = field.prefix(8) + "..." + field.suffix(8)
        HStack(spacing: 0) {
          Text("\(title):\(prefix)\t\t")
          Link(addressShortened, destination: url)
            .tint(ThemeColor.systemBlue.color)
        }
        .font(.subheadline)
      }
      else {
        Text("\(title):\(prefix)\t\t\(field)")
          .font(.subheadline)
      }
    }
    else {
      EmptyView()
    }
  }
}


struct SignTransactionViewModifier_Previews: PreviewProvider {
  static let store = Store<SignTransaction.State, SignTransaction.Action>(
    initialState: SignTransaction.State(
      typedDataResult: .init(
        id: "abc",
        expires: Date().addingTimeInterval(60*60),
        typedData: mockTypedData
      )
    ),
    reducer: SignTransaction()
  )

  static var previews: some View {
    Text("Signature request sheet")
      .sheet(isPresented: .constant(true)) {
        SignTransactionView(store: self.store)
      }
  }
}
