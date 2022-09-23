// Lentil

import ComposableArchitecture
import SwiftUI


struct PostView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          ProfileView(
            store: self.store.scope(
              state: \.profile,
              action: PostAction.profile
            )
          )
          
          if let creatorName = viewStore.post.profileName {
            VStack(alignment: .leading) {
              Text(creatorName)
                .fontWeight(.bold)
              Text(viewStore.post.profileHandle)
            }
            .font(.footnote)
          } else {
            Text(viewStore.post.profileHandle)
              .font(.footnote)
              .fontWeight(.bold)
          }
          
          VStack {
            Spacer()
            
            HStack(spacing: 8) {
              EmptyView()
              Text("·")
              Text(age(viewStore.post.createdAt))
            }
            .font(.footnote)
            
            Spacer()
          }
          .frame(height: 32)
        }
        
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

struct PostStatsView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 32) {
        
        HStack(spacing: 4) {
          HStack(spacing: 4) {
            Icon.upvote.view()
            Text("\(viewStore.post.upvotes)")
              .font(.footnote)
          }
          HStack(spacing: 4) {
            Icon.downvote.view()
            Text("\(viewStore.post.downvotes)")
              .font(.footnote)
          }
        }
        
        HStack(spacing: 4) {
          Icon.comment.view()
          Text("\(viewStore.post.comments)")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.mirror.view()
          Text("\(viewStore.post.mirrors)")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.collect.view()
          Text("\(viewStore.post.collects)")
            .font(.footnote)
        }
        
        Spacer()
        
        Icon.share.view()
      }
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
