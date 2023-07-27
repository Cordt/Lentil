// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import PhotosUI
import SDWebImageSwiftUI
import SwiftUI


struct CreatePublicationView: View {
  @FocusState private var textFieldIsFocused: Bool
  let store: Store<CreatePublication.State, CreatePublication.Action>
  
  @ViewBuilder
  func thumbnail(size: CGSize, _ rezisableImage: () -> some View, action: @escaping () -> Void) -> some View {
    ZStack(alignment: .topTrailing) {
      rezisableImage()
        .aspectRatio(contentMode: .fill)
        .frame(width: size.width, height: size.height)
        .clipped()
        .padding(.vertical)
      
      Button {
        action()
      } label: {
        Icon.times.view(.large)
          .foregroundColor(Theme.Color.white)
      }
      .frame(width: 25, height: 25)
      .background(Theme.Color.primary)
      .clipShape(Circle())
      .offset(x: 10, y: 5)
    }
  }
  
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
            
            HStack(spacing: 20) {
              if let image = viewStore.selectedPhoto {
                self.thumbnail(size: CGSizeMake(geometry.size.width * 0.50 - 10, geometry.size.height * 0.35)) {
                  Image(uiImage: image).resizable()
                } action: {
                  viewStore.send(.deleteImageTapped)
                }
              }
              if let selectedGif = viewStore.selectedGif {
                self.thumbnail(size: CGSizeMake(geometry.size.width * 0.50 - 10, geometry.size.height * 0.35)) {
                  WebImage(url: selectedGif.previewURL).resizable()
                } action: {
                  viewStore.send(.deleteGifTapped)
                }
              }
            }
            .disabled(viewStore.isPosting)
            .opacity(viewStore.isPosting ? 0.5 : 1.0)
            
            HStack {
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
                
              Button {
                viewStore.send(.selectGifTapped)
              } label: {
                Icon.otter.view(.xlarge)
              }
              .disabled(viewStore.selectedGif != nil || viewStore.isPosting)

            }
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
      .toolbar(.hidden, for: .tabBar)
      .navigationBarBackButtonHidden(true)
      .alert(
        self.store.scope(state: \.cancelAlert, action: { _ in CreatePublication.Action.cancelAlertDismissed }),
        dismiss: .cancelAlertDismissed
      )
      .fullScreenCover(
        unwrapping: viewStore.binding(
          get: \.selectGif,
          send: CreatePublication.Action.setSelectGif
        ),
        content: { _ in
          IfLetStore(
            self.store.scope(
              state: \.selectGif,
              action: CreatePublication.Action.selectGif
            )) { store in
              SelectGifView(store: store)
            }
        }
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
          initialState: CreatePublication.State(reason: .replyingToPost(MockData.mockPublications[0], "Satoshi")),
          reducer: { CreatePublication() }
        )
      )
    }
  }
}
#endif
