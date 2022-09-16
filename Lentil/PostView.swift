// Lentil

import ComposableArchitecture
import SwiftUI

struct PostState: Equatable, Identifiable {
  var post: Post
  
  var id: String { self.post.id }
}

enum PostAction: Equatable {}

let postReducer = Reducer<PostState, PostAction, Void> { state, action, _ in
  switch action {}
}

struct PostView: View {
  let store: Store<PostState, PostAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          Circle()
            .fill(viewStore.post.creatorProfile.profilePictureColor)
            .frame(width: 32)
          
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
        
        Text(viewStore.post.content)
          .font(.body)
      }
      .padding(.all)
      .background {
        RoundedRectangle(cornerRadius: 15)
          .fill(Color(red:0.95, green:0.95, blue: 0.95))
      }
      .padding([.leading, .trailing, .bottom])
    }
  }
}


struct PostView_Previews: PreviewProvider {
  static var previews: some View {
    PostView(
      store: .init(
        initialState: .init(post: mockPosts[0]),
        reducer: postReducer,
        environment: ()
      )
    )
  }
}
