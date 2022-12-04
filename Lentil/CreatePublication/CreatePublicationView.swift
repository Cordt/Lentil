// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import PhotosUI
import SwiftUI


struct CreatePublicationView: View {
  @FocusState private var textFieldIsFocused: Bool
  let store: Store<CreatePublication.State, CreatePublication.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        GeometryReader { geometry in
          VStack(alignment: .leading) {
            CreatePublicationInfoView(store: self.store)
            TextField(
              viewStore.placeholder,
              text: viewStore.binding(
                get: \.publicationText,
                send: CreatePublication.Action.publicationTextChanged
              ),
              axis: .vertical
            )
            .focused(self.$textFieldIsFocused)
            .lineLimit(100)
            .submitLabel(.return)
            .disabled(viewStore.isPosting)
            .opacity(viewStore.isPosting ? 0.5 : 1.0)
            
            Spacer()
            
            if let image = viewStore.selectedPhoto {
              ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.35)
                  .clipped()
                  .padding(.vertical)
                
                Button {
                  viewStore.send(.deleteImageTapped)
                } label: {
                  Icon.times.view(.large)
                    .foregroundColor(Theme.Color.white)
                }
                .frame(width: 25, height: 25)
                .background(Theme.Color.primary)
                .clipShape(Circle())
                .offset(x: 10, y: 5)
              }
              .disabled(viewStore.isPosting)
              .opacity(viewStore.isPosting ? 0.5 : 1.0)
            }
            
            PhotosPicker(
              selection: viewStore.binding(
                get: \.photoPickerItem,
                send: CreatePublication.Action.photoSelectionTapped
              ),
              matching: .images,
              photoLibrary: .shared()) {
                Image(systemName: "photo")
              }
              .disabled(viewStore.selectedPhoto != nil || viewStore.isPosting)
              .opacity(viewStore.isPosting ? 0.5 : 1.0)
          }
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
            .disabled(
              viewStore.publicationText.trimmingCharacters(in: .whitespacesAndNewlines) == ""
              || viewStore.isPosting
            )
        }
      }
      .toolbarBackground(.hidden, for: .navigationBar)
      .navigationBarBackButtonHidden(true)
      .alert(
        self.store.scope(state: \.cancelAlert),
        dismiss: .cancelAlertDismissed
      )
      .accentColor(Theme.Color.primary)
      .onAppear { self.textFieldIsFocused = true }
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
