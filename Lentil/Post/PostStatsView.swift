// Lentil

import ComposableArchitecture
import SwiftUI


struct PostStatsView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 16) {
        
        HStack(spacing: 4) {
          HStack(spacing: 4) {
            Icon.upvote.view()
            Text("\(viewStore.publication.upvotes)")
              .font(.footnote)
          }
          HStack(spacing: 4) {
            Icon.downvote.view()
            Text("\(viewStore.publication.downvotes)")
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

struct PostVotingView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(spacing: 8) {
        VStack(spacing: 4) {
          Icon.upvote.view()
          Text("\(viewStore.publication.upvotes)")
            .font(.caption2)
            .fixedSize(horizontal: true, vertical: true)
        }
        VStack(spacing: 4) {
          Text("\(viewStore.publication.downvotes)")
            .font(.caption2)
            .fixedSize(horizontal: true, vertical: true)
          
          Icon.downvote.view()
        }
      }
      .padding(.top, 2)
      .frame(maxWidth: 16)
    }
  }
}

struct PostStatsDetailView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 16) {
        HStack(spacing: 4) {
          Icon.comment.view()
          Text("\(viewStore.publication.comments) \(viewStore.publication.comments == 1 ? "Comment" : "Comments")")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.mirror.view()
          Text("\(viewStore.publication.mirrors) \(viewStore.publication.mirrors == 1 ? "Mirror" : "Mirrors")")
            .font(.footnote)
        }
        HStack(spacing: 4) {
          Icon.collect.view()
          Text("\(viewStore.publication.collects) \(viewStore.publication.collects == 1 ? "Collect" : "Collects")")
            .font(.footnote)
        }
        
        Spacer()
      }
    }
  }
}

struct PostStatsShortDetailView: View {
  let store: Store<Publication.State, Publication.Action>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 16) {
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
        
        HStack(alignment: .top) {
          PostVotingView(
            store: .init(
              initialState: .init(publication: mockPublications[0]),
              reducer: Publication()
            )
          )
          
          VStack {
            Rectangle()
              .fill(.gray)
              .frame(height: 150)
            
            PostStatsDetailView(
              store: .init(
                initialState: .init(publication: mockPublications[0]),
                reducer: Publication()
              )
            )
          }
        }
      }
      .padding(.bottom, 32)
      
      VStack {
        Rectangle()
          .fill(.gray)
          .frame(height: 32)
        
        HStack(alignment: .top) {
          PostVotingView(
            store: .init(
              initialState: .init(publication: mockPublications[2]),
              reducer: Publication()
            )
          )
          
          VStack {
            Rectangle()
              .fill(.gray)
              .frame(height: 150)
            
            PostStatsShortDetailView(
              store: .init(
                initialState: .init(publication: mockPublications[0]),
                reducer: Publication()
              )
            )
          }
        }
      }
      .padding(.leading, 24)
      .padding(.bottom, 32)
    }
    .padding()
  }
}
