// Lentil

import ComposableArchitecture
import SwiftUI


struct PostHeaderView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(alignment: .top) {
        ProfileView(
          store: self.store.scope(
            state: \.profile,
            action: PostAction.profile
          )
        )
        
        if let creatorName = viewStore.post.profileName {
          VStack(alignment: .leading) {
            Text(creatorName)
              .fontWeight(.bold)
            Text(viewStore.post.profileHandle)
          }
          .font(.footnote)
        } else {
          Text(viewStore.post.profileHandle)
            .font(.footnote)
            .fontWeight(.bold)
        }
        
        VStack {
          Spacer()
          
          HStack(spacing: 8) {
            EmptyView()
            Text("·")
            Text(age(viewStore.post.createdAt))
          }
          .font(.footnote)
          
          Spacer()
        }
        .frame(height: 32)
      }
    }
  }
}


struct PostHeaderView_Previews: PreviewProvider {
  
  static var previews: some View {
      PostHeaderView(
        store: .init(
          initialState: .init(post: mockPublications[0]),
          reducer: postReducer,
          environment: .mock
        )
      )
  }
}
