// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI
import XMTP


struct Message: Reducer {
  struct State: Equatable, Identifiable {
    var id: String
    var message: XMTP.DecodedMessage
    var from: Conversation.State.From
    var displayDate: Bool = false
  }
  
  enum Action: Equatable {}
  func reduce(into state: inout State, action: Action) -> Effect<Action> {}
}

struct MessageDateView: View {
  let store: StoreOf<Message>
  
  func label(for date: Date) -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
      return "Today"
    }
    else if calendar.isDateInYesterday(date) {
      return "Yesterday"
    }
    else {
      let formatter = DateFormatter()
      formatter.dateFormat = "E, d MMM yyyy"
      return formatter.string(from: date)
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      if viewStore.displayDate {
        Text(self.label(for: viewStore.message.sent))
          .font(style: .bodyBold, color: Theme.Color.text)
          .padding(.horizontal, 30)
          .padding(.vertical, 4)
          .background {
            RoundedRectangle(cornerRadius: Theme.wideRadius)
              .fill(Theme.Color.greyShade2.opacity(0.5))
          }
          .padding(.top, 20)
          .padding(.top, 10)
      }
    }
  }
}

struct MessageView: View {
  let store: StoreOf<Message>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      switch viewStore.from {
        case .user:
          Text(viewStore.message.bodyText)
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
          Text(viewStore.message.bodyText)
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
          MessageDateView(
            store: .init(
              initialState: .init(
                id: "abc-123",
                message: MockData.messages[0],
                from: .user,
                displayDate: true
              ),
              reducer: { Message() }
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-123",
                message: MockData.messages[0],
                from: .user,
                displayDate: true
              ),
              reducer: { Message() }
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-456",
                message: MockData.messages[1],
                from: .peer
              ),
              reducer: { Message() }
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-789",
                message: MockData.messages[2],
                from: .user
              ),
              reducer: { Message() }
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-def",
                message: MockData.messages[3],
                from: .user,
                displayDate: true
              ),
              reducer: { Message() }
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-ghi",
                message: MockData.messages[4],
                from: .peer
              ),
              reducer: { Message() }
            )
          )
          MessageView(
            store: .init(
              initialState: .init(
                id: "abc-jkl",
                message: MockData.messages[5],
                from: .user
              ),
              reducer: { Message() }
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
