// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI


struct CreatePublicationView: View {
  let store: Store<CreatePublication.State, CreatePublication.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        VStack {
          CreatePublicationInfoView(store: self.store)
          TextField(
            viewStore.placeholder,
            text: viewStore.binding(
              get: \.publicationText,
              send: CreatePublication.Action.publicationTextChanged
            ),
            axis: .vertical
          )
          .lineLimit(100)
          .submitLabel(.return)
          .disabled(viewStore.isPosting)
          .opacity(viewStore.isPosting ? 0.5 : 1.0)
          
          Spacer()
        }
        
        ProgressView { Text("Posting...") }
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 5)
              .fill(Theme.Color.white)
          )
          .disabled(!viewStore.isPosting)
          .opacity(!viewStore.isPosting ? 0 : 1.0)
        
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") { viewStore.send(.didTapCancel) }
            .disabled(viewStore.isPosting)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Post") { viewStore.send(.createPublication) }
            .disabled(viewStore.publicationText == "" || viewStore.isPosting)
        }
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .navigationBarBackButtonHidden(true)
      .accentColor(Theme.Color.primary)
    }
  }
}

private struct CreatePublicationInfoView: View {
  let store: Store<CreatePublication.State, CreatePublication.Action>
  
  @ViewBuilder
  func label(info: String, infoSuffix: String) -> some View {
    HStack(spacing: 0) {
      Text(info)
        .font(style: .annotation)
      Text(infoSuffix)
        .font(style: .annotation, color: Theme.Color.tertiary)
      Spacer()
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      if case .replyingToPost(_, let user) = viewStore.reason {
        self.label(info: "Replying to ", infoSuffix: "@\(user)'s post")
      }
      else if case .replyingToComment(_, let user) = viewStore.reason {
        self.label(info: "Replying to ", infoSuffix: "@\(user)'s comment")
      }
    }
  }
}


#if DEBUG
struct CreatePubicationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      CreatePublicationView(
        store: .init(
          initialState: CreatePublication.State(navigationId: "123", reason: .replyingToPost("abc", "Satoshi")),
          reducer: CreatePublication()
        )
      )
    }
  }
}
#endif
