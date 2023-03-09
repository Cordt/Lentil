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
    isIndexing: Bool,
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
      .disabled(isIndexing)
      
      Text("\(count)")
        .font(style: self.statsSize == .default ? .annotationSmall : .body, color: Theme.Color.text)
    }
    .opacity(isIndexing ? 0.35 : 1.0)
  }
  
  var body: some View {
    WithViewStore(self.store, observe: \.publication) { viewStore in
      HStack(spacing: 25) {
        self.view(
          for: .like,
          with: viewStore.state.upvotes,
          userInteracted: viewStore.state.upvotedByUser,
          isIndexing: viewStore.isIndexing,
          interaction: { viewStore.send(.toggleReaction) }
        )
        
        self.view(
          for: .comment,
          with: viewStore.state.comments,
          userInteracted: viewStore.state.commentdByUser,
          isIndexing: viewStore.isIndexing,
          interaction: { viewStore.send(.commentTapped) }
        )
        
        self.view(
          for: .mirror,
          with: viewStore.state.mirrors,
          userInteracted: viewStore.state.mirrordByUser,
          isIndexing: viewStore.isIndexing,
          interaction: { viewStore.send(.mirrorTapped) }
        )
        
        self.view(
          for: .collect,
          with: viewStore.state.collects,
          userInteracted: viewStore.state.collectdByUser,
          isIndexing: viewStore.isIndexing,
          interaction: { /* TODO: Collect publication */ }
        )
        
        Spacer()
        
        if viewStore.isIndexing { PulsingDot() }
        
        /* Icon.share.view() */
      }
      .font(style: .annotationSmall, color: Theme.Color.text)
    }
  }
}

#if DEBUG
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
    }
    .padding()
  }
}
#endif
