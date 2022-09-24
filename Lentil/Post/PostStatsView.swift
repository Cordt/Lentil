// Lentil

import ComposableArchitecture
import SwiftUI


struct PostStatsView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 16) {
        
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

struct PostVotingView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 16) {
        VStack(spacing: 4) {
          Icon.upvote.view()
          Text("\(viewStore.post.upvotes)")
            .font(.footnote)
        }
        VStack(spacing: 4) {
          Text("\(viewStore.post.downvotes)")
            .font(.footnote)
          Icon.downvote.view()
        }
        
        Spacer()
      }
      .padding(.top, 2)
    }
  }
}

struct PostStatsDetailView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 16) {
        HStack(spacing: 4) {
          Icon.comment.view()
          Text("\(viewStore.post.comments) \(viewStore.post.comments == 1 ? "Comment" : "Comments")")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.mirror.view()
          Text("\(viewStore.post.mirrors) \(viewStore.post.mirrors == 1 ? "Mirror" : "Mirrors")")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.collect.view()
          Text("\(viewStore.post.collects) \(viewStore.post.collects == 1 ? "Collect" : "Collects")")
            .font(.footnote)
        }
        
        Spacer()
      }
    }
  }
}


struct PostStats_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      VStack {
        Rectangle()
          .fill(.gray)
          .frame(height: 150)
        
        PostStatsView(
          store: .init(
            initialState: .init(post: mockPublications[0]),
            reducer: postReducer,
            environment: .mock
          )
        )
      }
      .padding(.bottom, 32)
      
      VStack {
        Rectangle()
          .fill(.gray)
          .frame(height: 32)
        
        HStack(alignment: .top) {
          PostVotingView(
            store: .init(
              initialState: .init(post: mockPublications[0]),
              reducer: postReducer,
              environment: .mock
            )
          )
          
          VStack {
            Rectangle()
              .fill(.gray)
              .frame(height: 150)
            
            PostStatsDetailView(
              store: .init(
                initialState: .init(post: mockPublications[0]),
                reducer: postReducer,
                environment: .mock
              )
            )
          }
        }
      }
      .padding(.bottom, 32)
    }
    .padding()
  }
}
