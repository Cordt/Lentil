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
      then: { self.modifier(SignTransactionView(store: $0)) },
      else: { self }
    )
  }
}

struct SignTransactionView: ViewModifier {
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

// FIXME: Need to emulate a store with optional state
//struct SignTransactionViewModifier_Previews: PreviewProvider {
//  static let state: SignTransaction.State? = .init(
//    typedDataResult: .init(
//      id: "abc",
//      expires: Date().addingTimeInterval(60*60),
//      typedData: mockTypedData
//    )
//  )
//  static let store = Store<SignTransaction.State?, SignTransaction.Action>(
//    initialState: state,
//    reducer: SignTransaction()
//  )
//
//  static var previews: some View {
//    WithViewStore(Self.store) { viewStore in
//      Button("Show signing sheet") {
//        viewStore.send(.setSheetPresented(true))
//      }
//      .signTransactionSheet(store: Self.store)
//    }
//  }
//}
