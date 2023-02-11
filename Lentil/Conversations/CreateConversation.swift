// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Dependencies
import IdentifiedCollections
import SwiftUI


struct CreateConversation: ReducerProtocol {
  struct State: Equatable {
    var searchText: String = ""
    var searchInFlight: Bool = false
    var searchResult: IdentifiedArrayOf<Model.Profile> = []
    var toast: Toast? = nil
  }
  
  enum Action: Equatable {
    case dismiss
    case updateSearchText(String)
    case startSearch
    case searchedProfilesResult(TaskResult<PaginatedResult<[Model.Profile]>>)
    case rowTapped(id: Model.Profile.ID)
    case dismissAndOpenConversation(_ conversation: XMTPConversation, _ userAddress: String)
    case failedToStartConversation
    case notLoggedInToLens
    case updateToast(Toast?)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.xmtpConnector) var xmtpConnector
  enum CancelSearchProfilesID {}
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .dismiss:
          return .none
          
        case .updateSearchText(let searchText):
          state.searchText = searchText
          if searchText.count >= 3 {
            state.searchInFlight = true
            return .merge(
              .cancel(id: CancelSearchProfilesID.self),
              .send(.startSearch)
            )
          }
          else {
            state.searchResult = []
            state.searchInFlight = false
            return .none
          }
          
        case .startSearch:
          return .task { [searchText = state.searchText] in
            return await .searchedProfilesResult(
              TaskResult {
                try await self.lensApi.searchProfiles(10, searchText)
              }
            )
          }
          .cancellable(id: CancelSearchProfilesID.self, cancelInFlight: true)
          
        case .searchedProfilesResult(.success(let result)):
          state.searchInFlight = false
          guard let address = try? self.xmtpConnector.address()
          else { return .none }
          
          state.searchResult = IdentifiedArrayOf(
            uniqueElements: result
              .data
              .filter { $0.ownedBy != address }
          )
          return .none
          
        case .searchedProfilesResult(.failure(let error)):
          state.searchInFlight = false
          log("Failed to search for profiles with query \(state.searchText)", level: .error, error: error)
          return .none
          
        case .rowTapped(let id):
          guard let userProfile = defaultsStorageApi.load(UserProfile.self) as? UserProfile
          else { return .send(.notLoggedInToLens) }
          
          guard let peerProfile = state.searchResult[id: id]
          else { return .none }
          
          return .run { send in
            let conversation = try await self.xmtpConnector.createConversation(
              peerProfile.ownedBy,
              .lens(peerProfile.id, userProfile.id)
            )
            let address = try self.xmtpConnector.address()
            self.cache.updateOrAppendProfile(peerProfile)
            await send(.dismissAndOpenConversation(conversation, address))
          }
          catch: { error, send in
            log("Failed to create conversation with \(peerProfile.ownedBy)", level: .error, error: error)
            await send(.failedToStartConversation)
          }
          
        case .dismissAndOpenConversation:
          state.searchResult = []
          state.searchText = ""
          return .none
          
        case .failedToStartConversation:
          state.toast = Toast(
            message: "This contact did not join the XMTP network yet.",
            duration: .long,
            isErrorMessage: true
          )
          return .none
          
        case .notLoggedInToLens:
          state.toast = Toast(
            message: "You need to log into Lens in order to create a chat with this person. Please do so on the feed tab.",
            duration: .long,
            isErrorMessage: true
          )
          return .none
          
        case .updateToast(let toast):
          state.toast = toast
          return .none
      }
    }
  }
}

struct CreateConversationView: View {
  @FocusState var searchFieldIsFocused: Bool
  let store: StoreOf<CreateConversation>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        VStack(spacing: 15) {
          HStack {
            Button("Cancel") { viewStore.send(.dismiss) }
            Spacer()
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
                  send: CreateConversation.Action.updateSearchText
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
        
        if viewStore.searchInFlight {
          ProgressView()
        }
        else {
          ScrollView(axes: .vertical, showsIndicators: false) {
            VStack {
              ForEach(viewStore.searchResult) { profile in
                Button {
                  viewStore.send(.rowTapped(id: profile.id))
                } label: {
                  ProfileRowView(profile: profile, profileImage: nil)
                }
              }
            }
          }
          .padding(.horizontal)
        }
        
        Spacer()
      }
      .toastView(
        toast: viewStore.binding(
          get: \.toast,
          send: CreateConversation.Action.updateToast
        )
      )
    }
  }
}


struct ProfileRowView: View {
  let profile: Model.Profile
  let profileImage: Image?
  
  var body: some View {
    HStack {
      if let image = self.profileImage {
        image
          .frame(width: 32, height: 32)
          .clipShape(Circle())
      }
      else {
        profileGradient(from: self.profile.handle)
          .frame(width: 32, height: 32)
      }
      
      if let name = self.profile.name {
        Text(name)
          .font(style: .bodyBold)
      }
      
      Text("@\(profile.handle)")
        .font(style: .body)
      
      Spacer()
    }
  }
}

#if DEBUG
struct CreateConversationView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      Color.clear
        .sheet(isPresented: .constant(true)) {
          CreateConversationView(
            store: .init(
              initialState: .init(),
              reducer: CreateConversation()
            )
          )
          
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.Color.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
  }
}
#endif
