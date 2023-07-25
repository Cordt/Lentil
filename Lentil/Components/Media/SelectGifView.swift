// Lentil
// Created by Laura and Cordt Zermin

import Combine
import ComposableArchitecture
import GiphyUISDK
import SDWebImageSwiftUI
import SwiftUI


struct GifController: Reducer {
  struct State: Equatable {
    var searchText: String = ""
    var searchResult: GPHContent = .trendingGifs
  }
  
  enum Action: Equatable {
    case dismiss
    case updateSearchText(_ text: String)
    case didSelectMedia(_ media: GiphyUISDK.GPHMedia)
    case didUpdateViewController(_ controller: GiphyGridController)
  }
  
  var body: some ReducerOf<GifController> {
    Reduce { state, action in
      switch action {
        case .dismiss:
          return .none
          
        case .updateSearchText(let text):
          state.searchText = text
          if state.searchText.count > 2 {
            state.searchResult = .search(withQuery: text, mediaType: .gif, language: .english)
          }
          else {
            state.searchResult = .trendingGifs
          }
          return .none
          
        case .didSelectMedia:
          return .none
          
        case .didUpdateViewController(let controller):
          controller.content = state.searchResult
          controller.update()
          return .none
      }
    }
  }
}


struct SelectGifView: View {
  @FocusState var searchFieldIsFocused: Bool
  let store: StoreOf<GifController>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        VStack(spacing: 15) {
          HStack {
            Button("Cancel") { viewStore.send(.dismiss) }
            
            Spacer()
            
            Image("poweredByGiphy")
              .resizable()
              .scaledToFit()
              .cornerRadius(Theme.defaultRadius)
          }
          
          ZStack {
            Rectangle()
              .foregroundColor(
                Theme.Color.greyShade3
                  .opacity(0.12)
              )
            HStack {
              Image(systemName: "magnifyingglass")
              TextField(
                "Search for profile handles ...",
                text: viewStore.binding(
                  get: \.searchText,
                  send: GifController.Action.updateSearchText
                )
              )
              .autocorrectionDisabled(true)
              .textInputAutocapitalization(.never)
              .focused($searchFieldIsFocused)
            }
            .foregroundColor(Theme.Color.greyShade3)
            .padding(.leading, 10)
            .onAppear { self.searchFieldIsFocused = true }
          }
          .frame(height: 40)
          .cornerRadius(Theme.defaultRadius)
        }
        .frame(height: 80)
        .padding()
        .background { Theme.Color.greyShade1 }
        
        GifControllerView(store: self.store)
          .padding(.horizontal)}
      
      Spacer()
    }
  }
}

struct GifControllerView: UIViewControllerRepresentable {
  let viewStore: ViewStoreOf<GifController>
  
  init(store: StoreOf<GifController>) {
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  func makeUIViewController(context: Context) -> some UIViewController {
    Giphy.configure(apiKey: LentilEnvironment.shared.giphyApiKey)
    
    let controller = GiphyGridController()
    controller.cellPadding = 5.0
    controller.direction = .vertical
    controller.numberOfTracks = 3
    controller.content = .trendingGifs
    controller.view.backgroundColor = UIColor(Theme.Color.white)
    controller.delegate = context.coordinator
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    guard let controller = uiViewController as? GiphyGridController
    else { return }
    
    viewStore.send(.didUpdateViewController(controller))
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  class Coordinator: GPHGridDelegate {
    let parent: GifControllerView
    
    init(parent: GifControllerView) {
      self.parent = parent
    }
    
    func contentDidUpdate(resultCount: Int, error: Error?) {}
    func didSelectMoreByYou(query: String) {}
    func didScroll(offset: CGFloat) {}
    
    func didSelectMedia(media: GiphyUISDK.GPHMedia, cell: UICollectionViewCell) {
      self.parent.viewStore.send(.didSelectMedia(media))
    }
  }
}


#if DEBUG
struct SelectGifView_Previews: PreviewProvider {
  static var previews: some View {
    SelectGifView(
      store: .init(
        initialState: .init(),
        reducer: { GifController() }
      )
    )
  }
}
#endif
