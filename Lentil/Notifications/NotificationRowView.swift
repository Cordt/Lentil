// Lentil

import ComposableArchitecture
import SDWebImageSwiftUI
import SwiftUI

struct NotificationRowView: View {
  let store: StoreOf<NotificationRow>
  
  var icon: some View {
    WithViewStore(self.store, observe: { $0.notification.event }) { viewStore in
      switch viewStore.state {
        case .followed:
          Icon.follow.view(.xlarge)
            .foregroundColor(Theme.Color.follow)
        case .collected:
          Icon.collect.view(.xlarge)
            .foregroundColor(Theme.Color.secondary)
        case .commented:
          Icon.comment.view(.xlarge)
            .foregroundColor(Theme.Color.primary)
        case .mirrored:
          Icon.mirror.view(.xlarge)
            .foregroundColor(Theme.Color.mirror)
        case .mentioned:
          Icon.mention.view(.xlarge)
            .foregroundColor(Theme.Color.mention)
        case .reacted:
          Icon.heartFilled.view(.xlarge)
            .foregroundColor(Theme.Color.tertiary)
      }
    }
  }
  
  func attributedLabel(profile: Model.Profile, event: Model.Notification.Event) -> AttributedString {
      var markdownString: String = ""
      if let name = profile.name { markdownString = "__\(name)__ @\(profile.handle)" }
      else { markdownString = "__@\(profile.handle)__" }
      
      switch event {
        case .followed:
          markdownString += " started following you"
        case .collected(let item):
          markdownString += " collected your \(item.name)"
        case .commented(let item, _):
          markdownString += " commented your \(item.name)"
        case .mirrored(let item):
          markdownString += " mirrored your \(item.name)"
        case .mentioned(let item):
          markdownString += " mentioned you in their \(item.name)"
        case .reacted:
          markdownString += " liked your post"
      }
      return try! AttributedString(markdown: markdownString)
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading) {
        HStack {
          self.icon
          
          WebImage(url: viewStore.notification.profile.profilePictureUrl)
            .resizable()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
          
          Spacer()
          
          Text(age(viewStore.notification.createdAt))
            .font(style: .annotation, color: Theme.Color.greyShade3)
        }
        
        Text(
          self.attributedLabel(
            profile: viewStore.notification.profile,
            event: viewStore.notification.event
          )
        )
        .font(style: .body)
        .padding(.leading, 35)
      }
    }
  }
}


#if DEBUG
struct NotificationRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ForEach(MockData.mockNotifications.sorted(by: { $0.createdAt > $1.createdAt }), id: \.id) {
        NotificationRowView(
          store: .init(
            initialState: .init(notification: $0),
            reducer: NotificationRow()
          )
        )
        .padding(5)
      }
    }
  }
}
#endif
