// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct CommentView: View {
  let store: Store<Comment.State, Comment.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading, spacing: 10) {
        PostHeaderView(
          store: self.store.scope(
            state: \.comment,
            action: Comment.Action.comment
          )
        )
        
        VStack(alignment: .leading, spacing: 10) {
          Text(viewStore.comment.shortenedContent)
            .font(style: .body)
            .multilineTextAlignment(.leading)
          
          PostStatsView(
            store: self.store.scope(
              state: \.comment,
              action: Comment.Action.comment
            )
          )
        }
        .offset(y: -25)
        .padding(.leading, 48)
      }
    }
  }
}

#if DEBUG
struct CommentView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 16) {
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: MockData.mockComments[0])),
          reducer: Comment()
        )
      )
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: MockData.mockComments[0])),
          reducer: Comment()
        )
      )
      CommentView(
        store: .init(
          initialState: .init(comment: .init(publication: MockData.mockComments[0])),
          reducer: Comment()
        )
      )
      Spacer()
    }
    .padding()
  }
}
#endif
