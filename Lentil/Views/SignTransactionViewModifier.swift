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
            fields: [
              ("ID", "id"),
              ("Expires in", "expires")
            ],
            data: metadata
          )
          
          dataSection(
            title: "Requested by",
            fields: [
              ("Name", "name"),
              ("Chain ID", "chainId"),
              ("Version", "version"),
              ("Contract", "verifyingContract")
            ],
            data: viewStore.typedDataResult.typedData.domain
          )
          
          dataSection(
            title: "Message",
            fields: [
              ("Profile ID", "profileId"),
              ("Nonce", "nonce"),
              ("Deadline", "deadline"),
              ("Wallet", "wallet")
            ],
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
  func dataSection(title: String, fields: [(String, String)], data: JSON) -> some View {
    Text("\(title)")
      .font(.subheadline)
      .fontWeight(.medium)
    
    Divider()
      .padding(.top, 8)
      .padding(.bottom, 16)
    
    VStack(alignment: .leading) {
      ForEach(fields, id: \.0) {
        dataFieldView(title: $0.0, from: data, id: $0.1)
      }
    }
    .padding(.bottom, 32)
  }
  
  @ViewBuilder
  func dataFieldView(title: String, from: JSON, id: String) -> some View {
    if let field = from[id]?.stringValue {
      HStack(spacing: 0) {
        HStack {
          Text("\(title):")
          Spacer()
        }
        .frame(width: 120)
        
        if field.prefix(2) == "0x" && field.count == 42,
           let explorerUrl = ProcessInfo.processInfo.environment["BLOCK_EXPLORER_URL"],
           let url = URL(string: explorerUrl + field) {
          
          let addressShortened = field.prefix(8) + "..." + field.suffix(8)
          Link(addressShortened, destination: url)
            .tint(ThemeColor.systemBlue.color)
        }
        else {
          Text("\(field)")
        }
        
        Spacer()
      }
      .font(.subheadline)
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
