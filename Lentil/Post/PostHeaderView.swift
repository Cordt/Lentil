// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SDWebImageSwiftUI
import SwiftUI


struct PostHeaderView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: \.publication) { viewStore in
      HStack(alignment: .top, spacing: 8) {
        PostProfilePicture(store: self.store)

        if let creatorName = viewStore.state.profile.name {
          HStack {
            Text(creatorName)
              .font(style: .bodyBold)
            Text("@\(viewStore.state.profile.handle)")
              .font(style: .body)
          }
          .truncationMode(.tail)

        } else {
          Text("@\(viewStore.state.profile.handle)")
            .font(style: .bodyBold)
            .truncationMode(.tail)
        }

        HStack(spacing: 8) {
          EmptyView()
          Text("·")
          Text(age(viewStore.state.createdAt))
        }
        .font(style: .body, color: Theme.Color.greyShade3)

        Spacer()
      }
      .lineLimit(1)
    }
  }
}

struct PostDetailHeaderView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: \.publication) { viewStore in
      HStack(alignment: .top, spacing: 8) {
        PostProfilePicture(store: self.store)
        
        VStack(alignment: .leading) {
          if let creatorName = viewStore.state.profile.name {
            HStack {
              Text(creatorName)
                .font(style: .bodyBold)
              Text("@\(viewStore.state.profile.handle)")
                .font(style: .body)
            }
            .truncationMode(.tail)
            
          } else {
            Text("@\(viewStore.state.profile.handle)")
              .font(style: .bodyBold)
              .truncationMode(.tail)
          }
          
          Text(age(viewStore.state.createdAt))
            .font(style: .body, color: Theme.Color.greyShade3)
        }
        
        Spacer()
      }
      .lineLimit(1)
    }
  }
}

fileprivate struct PostProfilePicture: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(
      self.store,
      observe: { $0.publication.profile }
    ) { viewStore in
      Button {
        viewStore.send(.userProfileTapped)
      } label: {
        if let url = viewStore.profilePictureUrl {
          WebImage(url: url)
            .resizable()
            .placeholder {
              profileGradient(from: viewStore.handle)
            }
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        }
        else {
          profileGradient(from: viewStore.handle)
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        }
      }
    }
  }
}


#if DEBUG
struct PostHeaderView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      PostHeaderView(
        store: .init(
          initialState: .init(publication: MockData.mockPublications[0]),
          reducer: { Publication() }
        )
      )
      
      PostHeaderView(
        store: .init(
          initialState: .init(publication: MockData.mockPublications[2]),
          reducer: { Publication() }
        )
      )
      
      PostDetailHeaderView(
        store: .init(
          initialState: .init(publication: MockData.mockPublications[0]),
          reducer: { Publication() }
        )
      )
      
      PostDetailHeaderView(
        store: .init(
          initialState: .init(publication: MockData.mockPublications[2]),
          reducer: { Publication() }
        )
      )
    }
    .padding()
  }
}
#endif
