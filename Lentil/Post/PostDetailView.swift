// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct PostDetailView: View {
  let store: StoreOf<Post>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0.post }) { viewStore in
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 10) {
          PostDetailHeaderView(
            store: self.store.scope(
              state: \.post,
              action: Post.Action.post
            )
          )
          
          IfLetStore(
            self.store.scope(
              state: \.post.remotePublicationImages,
              action: { Post.Action.post(action: .remotePublicationImages($0)) }
            )
          ) { imageStore in
            MultiImageView(store: imageStore)
              .frame(height: viewStore.state.publicationImageHeight)
            }
          
          Text(viewStore.state.publicationContent)
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
            PostView(store: $0)
          }
          
          Spacer()
        }
        .padding()
      }
      .padding(.top, 1)
      .mirrorConfirmationDialogue(store: self.store)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          BackButton { viewStore.send(.dismissView) }
        }
        ToolbarItem(placement: .principal) {
          Text("Post")
            .font(style: .headline, color: Theme.Color.primary)
        }
      }
      .toolbar(.hidden, for: .tabBar)
      .toolbarBackground(.hidden, for: .navigationBar)
      .navigationBarBackButtonHidden(true)
      .tint(Theme.Color.white)
      .task {
        await viewStore.send(.fetchComments)
          .finish()
      }
    }
  }
}

#if DEBUG
struct PostDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      PostDetailView(
        store: .init(
          initialState: .init(navigationId: "abc", post: Publication.State(publication: MockData.mockPublications[0]), typename: .post),
          reducer: Post()
        )
      )
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
#endif
