// Lentil

import ComposableArchitecture
import SwiftUI


struct ProfileView: View {
  let store: Store<ProfileState, ProfileAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Group {
        if let image = viewStore.picture {
          image
            .resizable()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
        } else {
          profileGradient(from: viewStore.handle)
            .frame(width: 32)
        }
      }
      .task {
        viewStore.send(.fetchProfilePicture)
      }
    }
  }
}


struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(
      store: .init(
        initialState: .init(
          handle: mockProfiles[0].handle,
          pictureUrl: mockProfiles[0].profilePictureUrl
        ),
        reducer: profileReducer,
        environment: .mock
      )
    )
  }
}
