// Lentil

import ComposableArchitecture
import GenericJSON
import SwiftUI
import web3

struct SignTransaction: ReducerProtocol {
  struct State: Equatable {
    var sheetIsPresented: Bool = false
    var typedDataResult: TypedDataResult
    
    var timerIsActive: Bool = true
    var expiresIn: String = ""
  }
  
  enum Action: Equatable {
    case setSheetPresented(Bool)
    case rejectTransaction
    case signTransaction
    case startTimer
    case timerTicked
    case stopTimer
    case sheetDismissed
  }
  
  @Dependency(\.mainQueue) var mainQueue
  private enum TimerID {}
  
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .setSheetPresented(let present):
        state.sheetIsPresented = present
        return .none
        
      case .rejectTransaction, .signTransaction:
        // Handled by parent reducer
        return .none
        
      case .startTimer:
        return .run { [isActive = state.timerIsActive] send in
          guard isActive else { return }
          for await _ in self.mainQueue.timer(interval: 1) {
            await send(.timerTicked)
          }
        }
        .cancellable(id: TimerID.self, cancelInFlight: true)
        
      case .timerTicked:
        let remainder = max(Int(state.typedDataResult.expires.timeIntervalSinceNow), 0)
        if remainder == 0 {
          state.timerIsActive = false
          return .none
        }
        state.expiresIn = String(remainder) + " sec"
        return .none
        
      case .stopTimer:
        return .cancel(id: TimerID.self)
     
      case .sheetDismissed:
        // Parent can perform cleanup logic
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
        .onAppear { viewStore.send(.startTimer) }
        .onDisappear { viewStore.send(.stopTimer) }
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
          let expiresIn = viewStore.expiresIn == "0" ? "expired" : viewStore.expiresIn
          let metadata = JSON(
            dictionaryLiteral:
              ("id", JSON(stringLiteral: viewStore.typedDataResult.id)),
              ("expires", JSON(stringLiteral: expiresIn))
          )
          
          dataSection(
            title: "Metadata",
            data: metadata
          )
          
          dataSection(
            title: "Requested by",
            data: viewStore.typedDataResult.typedData.domain
          )
          
          dataSection(
            title: "Message",
            data: viewStore.typedDataResult.typedData.message
          )
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
  func dataSection(title: String, data: JSON) -> some View {
    if let keys = data.objectValue?.keys {
      let fields: [(String, String)] = keys
        .compactMap { key in
          guard let value = data[keyPath: key]?.stringValue
          else { return nil }
          return (key.llamaToWords, value)
        }
        .sorted { $0.0 < $1.0 }
      Text("\(title)")
        .font(.subheadline)
        .fontWeight(.medium)
      
      Divider()
        .padding(.top, 8)
        .padding(.bottom, 16)
      
      VStack(alignment: .leading) {
        ForEach(fields, id: \.0) {
          dataFieldView(id: $0.0, value: $0.1)
        }
      }
      .padding(.bottom, 32)
    }
    else {
      EmptyView()
    }
  }
  
  @ViewBuilder
  func dataFieldView(id: String, value: String) -> some View {
    HStack(spacing: 0) {
      HStack {
        Text("\(id):")
        Spacer()
      }
      .frame(width: 140)
      
      if value.prefix(2) == "0x" && value.count == 42,
         let explorerUrl = ProcessInfo.processInfo.environment["BLOCK_EXPLORER_URL"],
         let url = URL(string: explorerUrl + value) {
        
        let addressShortened = value.prefix(8) + "..." + value.suffix(8)
        Link(addressShortened, destination: url)
          .tint(ThemeColor.systemBlue.color)
      }
      else {
        Text("\(value)")
      }
      
      Spacer()
    }
    .font(.subheadline)
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
