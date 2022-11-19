// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct ProfileView: View {
  @Environment(\.dismiss) var dismiss
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
                Text(viewStore.profile.name ?? "@\(viewStore.profile.handle)")
                  .font(style: .largeHeadline)
                
                if viewStore.profile.name != nil {
                  Text("@\(viewStore.profile.handle)")
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
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            BackButton { dismiss() }
          }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .accentColor(Theme.Color.primary)
        .task {
          viewStore.send(.loadProfile)
        }
      }
    }
  }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(
      store: .init(
        initialState: .init(profile: MockData.mockProfiles[2]),
        reducer: Profile()
      )
    )
  }
}
#endif
