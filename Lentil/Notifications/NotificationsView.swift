// Lentil

import ComposableArchitecture
import SwiftUI


struct NotificationsView: View {
  let store: StoreOf<Notifications>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ScrollView(axes: .vertical, showsIndicators: false) {
        LazyVStack {
          ForEachStore(
            self.store.scope(
              state: \.notificationRows,
              action: Notifications.Action.notificationRowAction
            ),
            content: NotificationRowView.init
          )
        }
        .padding()
        .onAppear { viewStore.send(.didAppear) }
      }
      .refreshable { await viewStore.send(.didRefresh).finish() }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          HStack {
            BackButton { viewStore.send(.didDismiss) }
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text("Notifications")
            .font(style: .headline, color: Theme.Color.text)
        }
      }
      .toolbar(.hidden, for: .tabBar)
      .toolbarBackground(.hidden, for: .navigationBar)
      .navigationBarBackButtonHidden(true)
      .navigationBarTitleDisplayMode(.inline)
      .tint(Theme.Color.white)
      .padding(.top, 1)
    }
  }
}


#if DEBUG
struct NotificationsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      NotificationsView(
        store: .init(
          initialState: .init(
            navigationId: "abc-def",
            notificationRows: [
              NotificationRow.State(notification: MockData.mockNotifications[0]),
              NotificationRow.State(notification: MockData.mockNotifications[1]),
              NotificationRow.State(notification: MockData.mockNotifications[2]),
              NotificationRow.State(notification: MockData.mockNotifications[3]),
              NotificationRow.State(notification: MockData.mockNotifications[4]),
              NotificationRow.State(notification: MockData.mockNotifications[5]),
            ]
          ),
          reducer: Notifications()
        )
      )
    }
  }
}
#endif
