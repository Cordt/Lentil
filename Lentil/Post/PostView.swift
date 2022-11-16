// Lentil
// Created by Laura and Cordt Zermin

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
        
        Group {
          Text(viewStore.post.shortenedContent)
            .font(style: .body)
          
          PostStatsView(
            store: self.store.scope(
              state: \.post,
              action: Post.Action.post
            )
          )
          .padding([.top], 4)
        }
        .offset(y: -15)
        .padding(.leading, 40)
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
          initialState: .init(post: Publication.State(publication: MockData.mockPublications[0])),
          reducer: Post()
        )
      )
    }
  }
}
