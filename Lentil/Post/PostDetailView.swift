// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct PostDetailView: View {
  @Environment(\.dismiss) var dismiss
  let store: Store<Post.State, Post.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 10) {
          PostDetailHeaderView(
            store: self.store.scope(
              state: \.post,
              action: Post.Action.post
            )
          )
          
          Text(viewStore.post.publicationContent)
            .font(style: .bodyDetailed)
          
          PostStatsView(
            store: self.store.scope(
              state: \.post,
              action: Post.Action.post
            ),
            statsSize: .large
          )
          .padding(.bottom, 16)
          
          ForEachStore(
            self.store.scope(
              state: \.comments,
              action: Post.Action.comment
            )
          ) {
            CommentView(store: $0)
          }
          .padding(.bottom, 16)
          
          Spacer()
        }
        .padding()
      }
      .padding(.top, 1)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          BackButton { dismiss() }
        }
        ToolbarItem(placement: .principal) {
          Text("Post")
            .font(style: .headline, color: Theme.Color.primary)
        }
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .navigationBarBackButtonHidden(true)
      .accentColor(Theme.Color.primary)
      .task {
        viewStore.send(.fetchComments)
      }
    }
  }
}

#if DEBUG
struct PostDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      PostDetailView(
        store: .init(
          initialState: .init(post: Publication.State(publication: MockData.mockPublications[0])),
          reducer: Post()
        )
      )
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
#endif
