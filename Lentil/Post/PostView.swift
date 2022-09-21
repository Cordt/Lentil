// Lentil

import ComposableArchitecture
import SwiftUI


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
            viewStore.post.profilePictureGradient
              .frame(width: 32)
          }
          
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
          
          Spacer()
          
          Text(age(viewStore.post.createdAt))
            .font(.footnote)
        }
        
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
    }
  }
}


struct PostView_Previews: PreviewProvider {
  static var previews: some View {
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
