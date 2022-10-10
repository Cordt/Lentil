// Lentil

import ComposableArchitecture
import GenericJSON
import SwiftUI
import web3

struct SignTransactionState: Equatable {
  var sheetIsPresented: Bool = false
  var typedDataResult: TypedDataResult
}

enum SignTransactionAction: Equatable {
  case setSheetPresented(Bool)
  case rejectTransaction
  case signTransaction
}


extension View {
  func signTransactionSheet(store: Store<SignTransactionState?, SignTransactionAction>) -> some View {
    IfLetStore(
      store,
      then: { self.modifier(SignTransaction(store: $0)) },
      else: { self }
    )
  }
}

struct SignTransaction: ViewModifier {
  let store: Store<SignTransactionState, SignTransactionAction>
  
  func body(content: Content) -> some View {
    WithViewStore(self.store) { viewStore in
      content
        .sheet(
          isPresented: viewStore.binding(
            get: { $0.sheetIsPresented },
            send: SignTransactionAction.setSheetPresented
          ),
          content: {
            VStack {
              Text("Signature request")
                .font(.title)
                .padding()
              
              TypedDataMessageView(
                typedData: viewStore.typedDataResult.typedData
              )
              
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
              
              Spacer()
            }
            .padding()
          }
        )
    }
  }
}

struct TypedDataMessageView: View {
  let typedData: TypedData
  
  var body: some View {
    Text("\(typedData.description)")
      .font(.body)
  }
}

let signTransactionReducer: Reducer<SignTransactionState, SignTransactionAction, Void> = Reducer { state, action, _ in
  switch action {
    case .setSheetPresented(let present):
      state.sheetIsPresented = present
      return .none
      
    case .rejectTransaction, .signTransaction:
      // Handled by parent reducer
      return .none
  }
}



struct SignTransactionViewModifier_Previews: PreviewProvider {
  static let store = Store<SignTransactionState?, SignTransactionAction>(
    initialState: .init(
      sheetIsPresented: true,
      typedDataResult: .init(
        id: "abc",
        expires: Date().addingTimeInterval(60*60),
        typedData: mockTypedData
      )
    ),
    reducer: signTransactionReducer.optional(),
    environment: ()
  )
  
  static var previews: some View {
    WithViewStore(Self.store) { viewStore in
      Button("Show signing sheet") {
        viewStore.send(.setSheetPresented(true))
      }
      .signTransactionSheet(store: Self.store)
    }
  }
}
