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
        if viewStore.typename == .mirror, let mirrorer = viewStore.mirrorer {
          PostInfoView(infoType: .mirrored, name: mirrorer)
        }
        
        PostHeaderView(
          store: self.store.scope(
            state: \.post,
            action: Post.Action.post
          )
        )
        
        
        VStack(alignment: .leading, spacing: 10) {
          IfLetStore(
            self.store.scope(
              state: \.post.remotePublicationImages,
              action: { Post.Action.post(action: .remotePublicationImages($0)) }
            ),
            then: { store in
              GeometryReader { reader in
                MultiImageView(store: store)
                  .frame(width: reader.size.width, height: viewStore.post.publicationImageHeight)
                  .clipped()
              }
              .frame(height: viewStore.post.publicationImageHeight)
            }
          )
          
          Button {
            viewStore.send(.postTapped)
          } label: {
            Text(viewStore.post.shortenedContent)
              .font(style: .body)
              .multilineTextAlignment(.leading)
          }
          
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
            .padding(.top, 30)
            .padding(.leading, -30)
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
        
        if viewStore.typename != .comment { Divider() }
      }
      .padding(viewStore.typename != .comment ? [.leading, .trailing, .top] : [])
      .onAppear { viewStore.send(.didAppear) }
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
  static var mockComment: () -> Model.Publication = {
    var tmp = MockData.mockPublications[2]
    tmp.typename = .comment(of: MockData.mockPublications[0])
    return tmp
  }
  static var previews: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 0) {
          PostView(
            store: .init(
              initialState: .init(
                navigationId: "abc", post: Publication.State(publication: MockData.mockPublications[0]),
                typename: .post,
                comments: [Post.State(
                  navigationId: "cba",
                  post: .init(publication: mockComment()),
                  typename: .comment
                )]
              ),
              reducer: Post()
            )
          )
          PostView(
            store: .init(
              initialState: .init(navigationId: "def", post: Publication.State(publication: MockData.mockPublications[1]), typename: .post),
              reducer: Post()
            )
          )
          PostView(
            store: .init(
              initialState: .init(navigationId: "ghi", post: Publication.State(publication: MockData.mockPublications[2]), typename: .post),
              reducer: Post()
            )
          )
          PostView(
            store: .init(
              initialState: .init(navigationId: "jkl", post: Publication.State(publication: MockData.mockPublications[3]), typename: .post),
              reducer: Post()
            )
          )
        }
      }
    }
  }
}
#endif
