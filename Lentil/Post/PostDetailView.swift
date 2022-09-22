// Lentil

import ComposableArchitecture
import SwiftUI


struct PostDetailView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        Text(age(viewStore.post.createdAt))
          .font(.footnote)
          .padding([.bottom], 5)
        
        Text(viewStore.post.content)
          .font(.body)
        
        Spacer()
      }
      .padding()
    }
  }
}

struct PostDetail_Previews: PreviewProvider {
  static var previews: some View {
    PostDetailView(
      store: .init(
        initialState: .init(post: mockPublications[0]),
        reducer: postReducer,
        environment: .mock
      )
    )
  }
}
