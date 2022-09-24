// Lentil

import ComposableArchitecture
import SwiftUI


struct PostDetailView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        PostHeaderView(store: self.store)
        
        Text(viewStore.post.content)
          .font(.body)
        
        Spacer()
      }
      .padding()
      .navigationTitle("Thread")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Icon.share.view(.large)
        }
      }
    }
  }
}

struct PostDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      PostDetailView(
        store: .init(
          initialState: .init(post: mockPublications[0]),
          reducer: postReducer,
          environment: .mock
        )
      )
    }
  }
}
