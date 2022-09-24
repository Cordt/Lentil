// Lentil

import ComposableArchitecture
import SwiftUI


struct PostView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        PostHeaderView(store: self.store)
        
        Text(viewStore.postContent)
          .font(.body)
        
        PostStatsView(store: self.store)
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
    }
  }
}


struct PostView_Previews: PreviewProvider {
  
  static var previews: some View {
    VStack(spacing: 0) {
      PostView(
        store: .init(
          initialState: .init(post: mockPublications[0]),
          reducer: postReducer,
          environment: .init(
            lensApi: .mock
          )
        )
      )
    }
  }
}
