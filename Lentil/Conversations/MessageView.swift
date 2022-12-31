// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI
import XMTP


struct Message: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: String
    var message: XMTP.DecodedMessage
    var from: Conversation.State.From
  }
  
  enum Action: Equatable {}
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {}
}

struct MessageView: View {
  let store: Store<Message.State, Message.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.from {
        case .user:
          Text(viewStore.message.body)
            .font(style: .body, color: Theme.Color.white)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .background {
              Rectangle()
                .fill(Theme.Color.secondary)
                .cornerRadius(Theme.wideRadius, corner: .topLeft)
                .cornerRadius(Theme.wideRadius, corner: .topRight)
                .cornerRadius(Theme.wideRadius, corner: .bottomLeft)
            }
          
        case .peer:
          Text(viewStore.message.body)
            .font(style: .body, color: Theme.Color.text)
            .fixedSize(horizontal: false, vertical: true)
            .padding(10)
            .background {
              Rectangle()
                .fill(Theme.Color.white)
                .cornerRadius(Theme.wideRadius, corner: .topLeft)
                .cornerRadius(Theme.wideRadius, corner: .topRight)
                .cornerRadius(Theme.wideRadius, corner: .bottomRight)
            }
      }
    }
  }
}

#if DEBUG
struct MessageView_Previews: PreviewProvider {
  
  static var previews: some View {
    ZStack {
      Theme.lentilGradient()
        .ignoresSafeArea()
      
      ScrollView {
        LazyVStack {
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-123",
                message: MockData.messages[0],
                from: .user
              ),
              reducer: Message()
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-456",
                message: MockData.messages[1],
                from: .peer
              ),
              reducer: Message()
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-789",
                message: MockData.messages[2],
                from: .user
              ),
              reducer: Message()
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-def",
                message: MockData.messages[3],
                from: .user
              ),
              reducer: Message()
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-ghi",
                message: MockData.messages[4],
                from: .peer
              ),
              reducer: Message()
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-jkl",
                message: MockData.messages[5],
                from: .user
              ),
              reducer: Message()
            )
          )
        }
        .padding()
      }
    }
  }
}
#endif

extension View {
  func cornerRadius(_ radius: CGFloat, corner: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corner))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
