// Lentil

import ComposableArchitecture
import SwiftUI


struct PostDetailView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading, spacing: 16) {
        PostHeaderView(store: self.store)
        
        HStack(alignment: .top, spacing: 16) {
          PostVotingView(store: self.store)
            .padding(.leading, 8)
          
          VStack(spacing: 16) {
            Text(viewStore.postContent)
              .font(.subheadline)
            
            PostStatsDetailView(store: self.store)
          }
        }
        
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
