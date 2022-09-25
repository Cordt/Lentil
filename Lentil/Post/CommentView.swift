// Lentil

import ComposableArchitecture
import SwiftUI


struct CommentView: View {
  let store: Store<CommentState, CommentAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading, spacing: 8) {
        PostHeaderView(
          store: self.store.scope(
            state: \.comment,
            action: CommentAction.comment
          )
        )

        HStack(alignment: .top, spacing: 16) {
          PostVotingView(
            store: self.store.scope(
              state: \.comment,
              action: CommentAction.comment
            )
          )
            .padding(.leading, 8)

          VStack(alignment: .leading, spacing: 8) {
            Text(viewStore.comment.shortenedContent)
              .font(.subheadline)

            PostStatsShortDetailView(
              store: self.store.scope(
                state: \.comment,
                action: CommentAction.comment
              )
            )
          }
        }
      }
      .padding([.leading, .trailing])
    }
  }
}

struct CommentView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 16) {
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: mockComments[0])),
          reducer: commentReducer,
          environment: .mock
        )
      )
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: mockComments[0])),
          reducer: commentReducer,
          environment: .mock
        )
      )
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: mockComments[0])),
          reducer: commentReducer,
          environment: .mock
        )
      )
      Spacer()
    }
  }
}
