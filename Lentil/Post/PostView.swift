// Lentil

import ComposableArchitecture
import SwiftUI


struct PostView: View {
  let store: Store<Post.State, Post.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        PostHeaderView(
          store: self.store.scope(
            state: \.post,
            action: Post.Action.post
          )
        )
        
        Text(viewStore.post.shortenedContent)
          .font(.subheadline)
        
        PostStatsView(
          store: self.store.scope(
            state: \.post,
            action: Post.Action.post
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
      .task {
        viewStore.send(.fetchReactions)
      }
    }
  }
}


struct PostView_Previews: PreviewProvider {
  
  static var previews: some View {
    VStack(spacing: 0) {
      PostView(
        store: .init(
          initialState: .init(post: Publication.State(publication: mockPublications[0])),
          reducer: Post()
        )
      )
    }
  }
}
