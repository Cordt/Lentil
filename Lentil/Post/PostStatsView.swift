// Lentil

import ComposableArchitecture
import SwiftUI


struct PostStatsView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 25) {
        
        HStack(spacing: 4) {
          HStack(spacing: 4) {
            Icon.heart.view()
            Text("\(viewStore.publication.upvotes)")
              .font(style: .body)
              .font(.footnote)
          }
        }
        
        HStack(spacing: 4) {
          Icon.comment.view()
          Text("\(viewStore.publication.comments)")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.mirror.view()
          Text("\(viewStore.publication.mirrors)")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.collect.view()
          Text("\(viewStore.publication.collects)")
            .font(.footnote)
        }
        
        Spacer()
        
        Icon.share.view()
      }
    }
  }
}

struct PostStats_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      VStack {
        Rectangle()
          .fill(.gray)
          .frame(height: 150)
        
        PostStatsView(
          store: .init(
            initialState: .init(publication: mockPublications[0]),
            reducer: Publication()
          )
        )
      }
      .padding(.bottom, 32)
      
      VStack {
        Rectangle()
          .fill(.gray)
          .frame(height: 32)
        
        Group {
          Rectangle()
            .fill(.gray)
            .frame(height: 150)
          
          PostStatsView(
            store: .init(
              initialState: .init(publication: mockPublications[0]),
              reducer: Publication()
            )
          )
        }
        .padding(.leading, 32)
      }
      .padding(.bottom, 32)
      
      VStack {
        Rectangle()
          .fill(.gray)
          .frame(height: 32)
        
        Group {
          Rectangle()
            .fill(.gray)
            .frame(height: 150)
          
          PostStatsView(
            store: .init(
              initialState: .init(publication: mockPublications[0]),
              reducer: Publication()
            )
          )
        }
        .padding(.leading, 32)
      }
      .padding(.bottom, 32)
    }
    .padding()
  }
}
