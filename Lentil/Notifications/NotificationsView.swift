// Lentil

import ComposableArchitecture
import SwiftUI


struct NotificationsView: View {
  let store: StoreOf<Notifications>
  
  var content: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      if viewStore.isLoading {
        ProgressView("Loading Notifications")
          .tint(Theme.Color.text)
      }
      else {
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
        }
        .refreshable { await viewStore.send(.didRefresh).finish() }
      }
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      self.content
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            HStack {
              BackButton { viewStore.send(.dismissView) }
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
        .onAppear { viewStore.send(.didAppear) }
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
            notificationRows: IdentifiedArray(uniqueElements: [
              NotificationRow.State(notification: MockData.mockNotifications[0]),
              NotificationRow.State(notification: MockData.mockNotifications[1]),
              NotificationRow.State(notification: MockData.mockNotifications[2]),
              NotificationRow.State(notification: MockData.mockNotifications[3]),
              NotificationRow.State(notification: MockData.mockNotifications[4]),
              NotificationRow.State(notification: MockData.mockNotifications[5]),
            ])
          ),
          reducer: { Notifications() }
        )
      )
    }
  }
}
#endif
