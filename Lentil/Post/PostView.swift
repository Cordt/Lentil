// Lentil

import ComposableArchitecture
import SwiftUI


struct PostView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        PostHeaderView(
          store: self.store.scope(
            state: \.post,
            action: PostAction.post
          )
        )
        
        Text(viewStore.post.shortenedContent)
          .font(.subheadline)
        
        PostStatsView(
          store: self.store.scope(
            state: \.post,
            action: PostAction.post
          )
        )
        .padding([.top], 4)
      }
      .padding(.all)
      .background(
        NavigationLink("") {
          PostDetailView(store: self.store)
        }
          .opacity(0)
      )
      .buttonStyle(.plain)
    }
  }
}


struct PostView_Previews: PreviewProvider {
  
  static var previews: some View {
    VStack(spacing: 0) {
      PostView(
        store: .init(
          initialState: .init(post: .init(publication: mockPublications[0])),
          reducer: postReducer,
          environment: .init(
            lensApi: .mock
          )
        )
      )
    }
  }
}
