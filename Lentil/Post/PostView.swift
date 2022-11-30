// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct PostView: View {
  let store: Store<Post.State, Post.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        if viewStore.comments.count > 0, let commenter = viewStore.commenter {
          PostInfoView(infoType: .commented, name: commenter)
        }
        PostHeaderView(
          store: self.store.scope(
            state: \.post,
            action: Post.Action.post
          )
        )
        
        Button {
          viewStore.send(.postTapped)
        } label: {
          VStack(alignment: .leading, spacing: 10) {
            if let image = viewStore.post.publicationImage {
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            }
            
            Text(viewStore.post.shortenedContent)
              .font(style: .body)
              .multilineTextAlignment(.leading)
            
            PostStatsView(
              store: self.store.scope(
                state: \.post,
                action: Post.Action.post
              )
            )
          }
          .background {
            if viewStore.comments.count > 0 {
              HStack {
                Rectangle()
                  .fill(Theme.Color.greyShade3)
                  .frame(width: 1)
                Spacer()
              }
              .padding(.top, 28)
              .padding(.leading, -28)
            }
          }
        }
        .padding(.top, -25)
        .padding(.bottom, 5)
        .padding(.leading, 48)
        
        ForEachStore(self.store.scope(
          state: \.comments,
          action: Post.Action.comment
        )) { commentStore in
          PostView(store: commentStore)
        }
        
        Divider()
      }
      .padding([.leading, .trailing, .top])
      .onAppear { viewStore.send(.didAppear) }
      .task {
        await viewStore.send(
          .post(action: .remotePublicationImage(.fetchImage))
        )
        .finish()
      }
      .id(viewStore.id)
    }
  }
}

struct PostInfoView: View {
  enum InfoType {
    case commented
    case mirrored
  }
  
  var infoType: InfoType
  var name: String
  
  var body: some View {
    HStack(spacing: 5) {
      switch self.infoType {
        case .commented:
          Icon.comment.view()
            .foregroundColor(Theme.Color.text)
          Text(self.name)
            .font(style: .annotation, color: Theme.Color.text)
          Text("commented on this")
            .font(style: .annotation, color: Theme.Color.greyShade3)
          
        case .mirrored:
          Icon.mirror.view()
            .foregroundColor(Theme.Color.text)
          Text(self.name)
            .font(style: .annotation, color: Theme.Color.text)
          Text("mirrored this")
            .font(style: .annotation, color: Theme.Color.greyShade3)
      }
    }
  }
}


#if DEBUG
struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 0) {
          PostView(
            store: .init(
              initialState: .init(
                navigationId: "abc", post: Publication.State(publication: MockData.mockPublications[0]),
                comments: [Post.State(navigationId: "abc", post: .init(publication: MockData.mockPublications[2]))]
              ),
              reducer: Post()
            )
          )
          PostView(
            store: .init(
              initialState: .init(navigationId: "abc", post: Publication.State(publication: MockData.mockPublications[1])),
              reducer: Post()
            )
          )
        }
      }
    }
  }
}
#endif
