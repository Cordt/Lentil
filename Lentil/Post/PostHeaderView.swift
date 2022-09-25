// Lentil

import ComposableArchitecture
import SwiftUI


struct PostHeaderView: View {
  let store: Store<PublicationState, PublicationAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 8) {
        ProfileView(
          store: self.store.scope(
            state: \.profile,
            action: PublicationAction.profile
          )
        )
        
        if let creatorName = viewStore.publication.profileName {
          VStack(alignment: .leading) {
            Text(creatorName)
              .fontWeight(.bold)
            Text(viewStore.publication.profileHandle)
          }
          .font(.footnote)
        } else {
          Text(viewStore.publication.profileHandle)
            .font(.footnote)
            .fontWeight(.bold)
        }
        
        HStack(spacing: 8) {
          EmptyView()
          Text("·")
          Text(age(viewStore.publication.createdAt))
        }
        .font(.footnote)
        .frame(height: 32)
        
        Spacer()
      }
    }
  }
}


struct PostHeaderView_Previews: PreviewProvider {
  
  static var previews: some View {
    VStack {
      PostHeaderView(
        store: .init(
          initialState: .init(publication: mockPublications[0]),
          reducer: publicationReducer,
          environment: .mock
        )
      )
      
      PostHeaderView(
        store: .init(
          initialState: .init(publication: mockPublications[2]),
          reducer: publicationReducer,
          environment: .mock
        )
      )
    }
    .padding()
  }
}