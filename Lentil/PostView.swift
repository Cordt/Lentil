// Lentil

import ComposableArchitecture
import SwiftUI

struct PostState: Equatable, Identifiable {
  var post: Post
  var profilePicture: Image?
  
  private let maxLength: Int = 256
  
  var postContent: String {
    if self.post.content.count > self.maxLength {
      return String(self.post.content.prefix(self.maxLength)) + "..."
    }
    else {
      return self.post.content
    }
  }
  
  var id: String { self.post.id }
}

enum PostAction: Equatable {
  case fetchProfilePicture
  case updateProfilePicture(TaskResult<Image>)
}

let postReducer = Reducer<PostState, PostAction, AppEnvironment> { state, action, env in
  switch action {
    case .fetchProfilePicture:
      return .task { [url = state.post.creatorProfile.profilePictureUrl] in
        await .updateProfilePicture(
          TaskResult { try await env.lensApi.getProfilePicture(url) }
        )
      }
      
    case .updateProfilePicture(let .success(profilePicture)):
      state.profilePicture = profilePicture
      return .none
      
    case .updateProfilePicture(.failure):
      // Handle error
      return .none
  }
}

struct PostView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          if let image = viewStore.profilePicture {
            image
              .resizable()
              .frame(width: 32, height: 32)
              .clipShape(Circle())
          } else {
            Circle()
              .fill(viewStore.post.creatorProfile.profilePictureColor)
              .frame(width: 32)
          }
          
          if let creatorName = viewStore.post.creatorProfile.name {
            VStack(alignment: .leading) {
              Text(creatorName)
                .fontWeight(.bold)
              Text(viewStore.post.creatorProfile.handle)
            }
            .font(.footnote)
          } else {
            Text(viewStore.post.creatorProfile.handle)
              .font(.footnote)
              .fontWeight(.bold)
          }
          
          Spacer()
          
          Text(age(viewStore.post.createdAt))
            .font(.footnote)
        }
        
        Text(viewStore.post.name)
          .font(.headline)
          .padding([.top, .bottom], 5)
        
        Text(viewStore.postContent)
          .font(.body)
      }
      .padding(.all)
      .background {
        RoundedRectangle(cornerRadius: 15)
          .fill(Color(red:0.95, green:0.95, blue: 0.95))
      }
      .padding([.leading, .trailing, .bottom])
      .background(
        NavigationLink("") {
          PostDetailView(store: self.store)
        }
          .opacity(0)
      )
      .buttonStyle(.plain)
      .task {
        viewStore.send(.fetchProfilePicture)
      }
    }
  }
}

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
      .navigationTitle(viewStore.post.name)
    }
  }
}


struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    PostView(
      store: .init(
        initialState: .init(post: mockPosts[0]),
        reducer: postReducer,
        environment: .init(
          lensApi: .mock
        )
      )
    )
  }
}
