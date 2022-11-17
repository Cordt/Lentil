// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct PostStatsView: View {
  enum StatsSize {
    case `default`, large
  }
  
  private enum StatsElement {
    case like, comment, mirror, collect
  }
  
  let store: Store<Publication.State, Publication.Action>
  var statsSize: StatsSize = .default
  
  private func view(
    for element: StatsElement,
    with count: Int,
    userInteracted: Bool,
    interaction: @escaping () -> ()
  ) -> some View {
    func icon() -> Icon {
      switch element {
        case .like:     return userInteracted ? Icon.heartFilled : Icon.heart
        case .comment:  return Icon.comment
        case .mirror:   return Icon.mirror
        case .collect:  return Icon.collect
      }
    }
    
    return HStack(spacing: 4) {
      Button {
        interaction()
      } label: {
        icon()
          .view(self.statsSize == .default ? .default : .large)
          .foregroundColor(userInteracted ? Theme.Color.tertiary : Theme.Color.text)
      }
      Text("\(count)")
        .font(style: self.statsSize == .default ? .annotationSmall : .body, color: Theme.Color.text)
    }
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack(spacing: 25) {
        self.view(
          for: .like,
          with: viewStore.publication.upvotes,
          userInteracted: viewStore.publication.upvotedByUser,
          interaction: { viewStore.send(.toggleReaction) }
        )
        
        self.view(
          for: .comment,
          with: viewStore.publication.comments,
          userInteracted: viewStore.publication.commentdByUser,
          interaction: { /* TODO: Open detail + comment */ }
        )
        
        self.view(
          for: .mirror,
          with: viewStore.publication.mirrors,
          userInteracted: viewStore.publication.mirrordByUser,
          interaction: { /* TODO: Mirror publication */ }
        )
        
        self.view(
          for: .collect,
          with: viewStore.publication.collects,
          userInteracted: viewStore.publication.collectdByUser,
          interaction: { /* TODO: Collect publication */ }
        )
        
        Spacer()
        
        /* Icon.share.view() */
      }
      .font(style: .annotationSmall, color: Theme.Color.text)
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
            initialState: .init(publication: MockData.mockPublications[0]),
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
              initialState: .init(publication: MockData.mockPublications[1]),
              reducer: Publication()
            ),
            statsSize: .large
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
              initialState: .init(publication: MockData.mockPublications[2]),
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
