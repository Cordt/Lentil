// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct PostHeaderView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(alignment: .top, spacing: 8) {
        if let image = viewStore.profilePicture {
          image
            .resizable()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
        } else {
          profileGradient(from: viewStore.publication.profileHandle)
            .frame(width: 32, height: 32)
        }
        
        if let creatorName = viewStore.publication.profileName {
          HStack {
            Text(creatorName)
              .font(style: .bodyBold)
            Text(viewStore.publication.profileHandle)
              .font(style: .body)
          }
          .truncationMode(.tail)
          
        } else {
          Text(viewStore.publication.profileHandle)
            .font(style: .bodyBold)
            .truncationMode(.tail)
        }
        
        HStack(spacing: 8) {
          EmptyView()
          Text("·")
          Text(age(viewStore.publication.createdAt))
        }
        .font(style: .body, color: Theme.Color.greyShade3)
        
        Spacer()
      }
      .lineLimit(1)
      .task { viewStore.send(.remoteProfilePicture(.fetchImage)) }
    }
  }
}

struct PostDetailHeaderView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(alignment: .top, spacing: 8) {
        if let image = viewStore.profilePicture {
          image
            .resizable()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
        } else {
          profileGradient(from: viewStore.publication.profileHandle)
            .frame(width: 32, height: 32)
        }
        
        VStack(alignment: .leading) {
          if let creatorName = viewStore.publication.profileName {
            HStack {
              Text(creatorName)
                .font(style: .bodyBold)
              Text(viewStore.publication.profileHandle)
                .font(style: .body)
            }
            .truncationMode(.tail)
            
          } else {
            Text(viewStore.publication.profileHandle)
              .font(style: .bodyBold)
              .truncationMode(.tail)
          }

          Text(age(viewStore.publication.createdAt))
            .font(style: .body, color: Theme.Color.greyShade3)
        }
        
        Spacer()
      }
      .lineLimit(1)
      .task { viewStore.send(.remoteProfilePicture(.fetchImage)) }
    }
  }
}

struct PostHeaderView_Previews: PreviewProvider {
  
  static var previews: some View {
    VStack {
      PostHeaderView(
        store: .init(
          initialState: .init(publication: mockPublications[0]),
          reducer: Publication()
        )
      )
      
      PostHeaderView(
        store: .init(
          initialState: .init(publication: mockPublications[2]),
          reducer: Publication()
        )
      )
      
      PostDetailHeaderView(
        store: .init(
          initialState: .init(publication: mockPublications[0]),
          reducer: Publication()
        )
      )
      
      PostDetailHeaderView(
        store: .init(
          initialState: .init(publication: mockPublications[2]),
          reducer: Publication()
        )
      )
    }
    .padding()
  }
}
