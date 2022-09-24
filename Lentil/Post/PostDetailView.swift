// Lentil

import ComposableArchitecture
import SwiftUI


struct PostDetailView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 16) {
          PostHeaderView(
            store: self.store.scope(
              state: \.post,
              action: PostAction.post
            )
          )
          
          HStack(alignment: .top, spacing: 16) {
            PostVotingView(
              store: self.store.scope(
                state: \.post,
                action: PostAction.post
              )
            )
            .padding(.leading, 8)
            
            VStack(alignment: .leading, spacing: 16) {
              Text(viewStore.post.publicationContent)
                .font(.subheadline)
              
              PostStatsDetailView(
                store: self.store.scope(
                  state: \.post,
                  action: PostAction.post
                )
              )
            }
          }
          
          ForEachStore(
            self.store.scope(
              state: \.comments,
              action: PostAction.comment
            )
          ) {
            CommentView(store: $0)
          }
          .padding(.leading, 24)
          
          Spacer()
        }
      }
      .padding()
      .navigationTitle("Thread")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Icon.share.view(.large)
        }
      }
      .task {
        viewStore.send(.fetchComments)
      }
    }
  }
}

struct PostDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      PostDetailView(
        store: .init(
          initialState: .init(post: .init(publication: mockPublications[0])),
          reducer: postReducer,
          environment: .mock
        )
      )
    }
  }
}
