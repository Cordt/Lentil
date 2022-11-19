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
        
        NavigationLink(
          destination: { PostDetailView(store: self.store) },
          label: {
            VStack(alignment: .leading, spacing: 10) {
              if let image = viewStore.post.publicationImage {
                image
                  .resizable()
                  .scaledToFit()
              }
              
              Text(viewStore.post.shortenedContent)
                .font(style: .body)
                .multilineTextAlignment(.leading)
              
              PostStatsView(
                store: self.store.scope(
                  state: \.post,
                  action: Post.Action.post
                )
              )
            }
          }
        )
        .offset(y: -25)
        .padding(.leading, 48)
      }
      .padding([.leading, .trailing, .top])
      .task {
        viewStore.send(.post(action: .remotePublicationImage(.fetchImage)))
      }
    }
  }
}


#if DEBUG
struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 0) {
      PostView(
        store: .init(
          initialState: .init(post: Publication.State(publication: MockData.mockPublications[0])),
          reducer: Post()
        )
      )
      PostView(
        store: .init(
          initialState: .init(post: Publication.State(publication: MockData.mockPublications[1])),
          reducer: Post()
        )
      )
    }
  }
}
#endif
