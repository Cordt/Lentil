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
          TextField(
            "Share your thoughts!",
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


#if DEBUG
struct CreatePubicationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CreatePublicationView(
        store: .init(
          initialState: CreatePublication.State(),
          reducer: CreatePublication()
        )
      )
    }
  }
}
#endif
