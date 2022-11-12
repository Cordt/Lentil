// Lentil

import ComposableArchitecture
import SwiftUI


struct Profile: ReducerProtocol {
  struct State: Equatable {
    var profile: Model.Profile
    
    var coverPicture: Image?
    var remoteCoverPicture: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.profile.coverPictureUrl,
          image: self.coverPicture
        )
      }
      set {
        self.coverPicture = newValue.image
      }
    }
    var profilePicture: Image?
    var remoteProfilePicture: RemoteImage.State {
      get {
        RemoteImage.State(
          imageUrl: self.profile.profilePictureUrl,
          image: self.profilePicture
        )
      }
      set {
        self.profilePicture = newValue.image
      }
    }
  }
  
  enum Action: Equatable {
    case remoteCoverPicture(RemoteImage.Action)
    case remoteProfilePicture(RemoteImage.Action)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.remoteCoverPicture, action: /Action.remoteCoverPicture) {
      RemoteImage()
    }
    Scope(state: \.remoteProfilePicture, action: /Action.remoteProfilePicture) {
      RemoteImage()
    }
    
    Reduce { state, action in
      switch action {
        case .remoteCoverPicture, .remoteProfilePicture:
          return .none
      }
    }
  }
}

struct ProfileView: View {
  let store: Store<Profile.State, Profile.Action>
  
  @ViewBuilder
  func lazy(image: Image?, placeholder: some View) -> some View {
    if let image {
      image
        .resizable()
    } else {
      placeholder
    }
  }
  
  @ViewBuilder
  func linkIcon(icon: Icon, url: URL) -> some View {
    Theme.Color.white
      .opacity(0.7)
      .clipShape(Circle())
      .overlay {
        icon.view()
          .foregroundColor(Theme.Color.tertiary)
      }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      GeometryReader { geometry in
        VStack(spacing: 0) {
          lazy(image: viewStore.coverPicture, placeholder: Theme.Color.primary)
            .frame(height: geometry.size.height * 0.35)
          
          VStack(alignment: .leading) {
            HStack {
              VStack(alignment: .leading) {
                Spacer()
                Text(viewStore.profile.name ?? viewStore.profile.handle)
                  .font(style: .largeHeadline)
                
                if viewStore.profile.name != nil {
                  Text(viewStore.profile.handle)
                    .font(style: .body)
                }
              }
              .frame(height: 112)
              
              Spacer()
              
              lazy(image: viewStore.profilePicture, placeholder: profileGradient(from: viewStore.profile.handle))
                .frame(width: 112, height: 112)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Theme.Color.white, lineWidth: 1.0))
            }
            .padding(.bottom, 5)
            
            if let bio = viewStore.profile.bio {
              Text(bio)
                .font(style: .annotation, color: Theme.Color.greyShade3)
                .padding(.bottom, 5)
            }
            
            HStack {
              VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                  Text(simpleCount(from: viewStore.profile.followers))
                    .font(style: .bodyBold)
                  Text("Follower")
                    .font(style: .body)
                }
                HStack {
                  if let location = viewStore.profile.location {
                    Icon.location.view()
                    Text(location)
                      .font(style: .body)
                  }
                }
              }
              .padding(.trailing, 10)
              VStack(alignment: .leading, spacing: 5) {
                HStack {
                  Text(simpleCount(from: viewStore.profile.following))
                    .font(style: .bodyBold)
                  Text("Following")
                    .font(style: .body)
                }
                HStack {
                  Icon.lens.view()
                  Text("Joined " + age(viewStore.profile.joinedDate))
                    .font(style: .body)
                }
              }
            }
          }
          .offset(y: -48)
          .padding([.leading, .trailing])
        }
        .ignoresSafeArea()
        .task {
          viewStore.send(.remoteCoverPicture(.fetchImage))
          viewStore.send(.remoteProfilePicture(.fetchImage))
        }
      }
    }
  }
}


struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(
      store: .init(
        initialState: .init(profile: mockProfiles[2]),
        reducer: Profile()
      )
    )
  }
}
