// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct ProfileView: View {
  let store: Store<Profile.State, Profile.Action>
  
  @ViewBuilder
  func linkIcon(icon: Icon, url: URL) -> some View {
    Link(destination: url) {
      icon.view(.xlarge)
        .frame(width: 40, height: 40)
        .background { Theme.Color.white.opacity(0.7) }
        .clipShape(Circle())
    }
    .tint(Theme.Color.tertiary)
    .padding([.top, .leading, .bottom], 10)
  }
  
  @ViewBuilder
  func cover(width: CGFloat, height: CGFloat) -> some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack(alignment: .bottomLeading) {
        IfLetStore(
          self.store.scope(
            state: \.remoteCoverPicture,
            action: Profile.Action.remoteCoverPicture
          ),
          then: {
            LentilImageView(store: $0)
              .frame(width: width, height: height)
              .clipped()
          },
          else: {
            lentilGradient()
              .frame(width: width, height: height)
          }
        )
        HStack {
          if let twitter = viewStore.twitterURL {
            self.linkIcon(icon: Icon.twitter, url: twitter)
          }
          
          if let website = viewStore.websiteURL {
            self.linkIcon(icon: Icon.website, url: website)
          }
        }
      }
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      GeometryReader { geometry in
        VStack(spacing: 0) {
          self.cover(width: geometry.size.width, height: geometry.size.height * 0.35)
          
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
              
              IfLetStore(
                self.store.scope(
                  state: \.remoteProfilePicture,
                  action: Profile.Action.remoteProfilePicture
                ),
                then: {
                  LentilImageView(store: $0)
                    .frame(width: 112, height: 112)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Theme.Color.white, lineWidth: 1.0))
                },
                else: {
                  profileGradient(from: viewStore.profile.handle)
                    .frame(width: 112, height: 112)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Theme.Color.white, lineWidth: 1.0))
                }
              )
            }
            .padding(.bottom, 5)
            
            if let bio = viewStore.profile.bio {
              Text(bio)
                .font(style: .annotation, color: Theme.Color.greyShade3)
                .padding(.bottom, 5)
            }
            
            HStack(alignment: .top) {
              VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                  Text(simpleCount(from: viewStore.profile.followers))
                    .font(style: .bodyBold)
                  Text(viewStore.profile.followers == 1 ? "Follower" : "Followers")
                    .font(style: .body)
                }
                HStack {
                  if let joined = viewStore.profile.joinedDate {
                    Icon.lens.view()
                    Text("Joined " + age(joined))
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
                  if let location = viewStore.profileLocation {
                    Icon.location.view()
                    Text(location)
                      .font(style: .body)
                  }
                }
              }
            }
          }
          .padding(.top, -48)
          .padding([.leading, .trailing])
          
          ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading) {
              ForEachStore(
                self.store.scope(
                  state: \.posts,
                  action: Profile.Action.post
                )
              ) { store in
                PostView(store: store)
              }
            }
          }
        }
        .ignoresSafeArea()
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            BackButton { viewStore.send(.dismissView) }
          }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .accentColor(Theme.Color.primary)
        .task {
          await viewStore.send(.didAppear)
            .finish()
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
        initialState: .init(navigationId: "abc", profile: MockData.mockProfiles[2]),
        reducer: Profile()
      )
    )
  }
}
#endif
