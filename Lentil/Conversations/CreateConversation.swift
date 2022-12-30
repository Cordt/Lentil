// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Dependencies
import IdentifiedCollections
import SwiftUI


struct CreateConversation: ReducerProtocol {
  struct State: Equatable {
    var searchText: String = ""
    var searchResult: IdentifiedArrayOf<Model.Profile> = []
  }
  
  enum Action: Equatable {
    case dismiss
    case updateSearchText(String)
    case searchedProfilesResult(TaskResult<QueryResult<[Model.Profile]>>)
    case rowTapped(id: Model.Profile.ID)
    case dismissAndOpenConversation(_ conversation: XMTPConversation, _ userAddress: String)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.xmtpConnector) var xmtpConnector
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .dismiss:
        return .none
        
      case .updateSearchText(let searchText):
        state.searchText = searchText
        if searchText.count >= 3 {
          return .task {
            await .searchedProfilesResult(
              TaskResult {
                try await self.lensApi.searchProfiles(10, searchText)
              }
            )
          }
        }
        else {
          return .none
        }
        
      case .searchedProfilesResult(.success(let result)):
        state.searchResult = IdentifiedArrayOf(uniqueElements: result.data)
        return .none
        
      case .searchedProfilesResult(.failure(let error)):
        log("Failed to search for profiles with query \(state.searchText)", level: .error, error: error)
        return .none
        
      case .rowTapped(let id):
        guard let profile = state.searchResult[id: id]
        else { return .none }
        
        state.searchResult = []
        state.searchText = ""
        return .run { send in
          let conversation = try await self.xmtpConnector.createConversation(profile.ownedBy)
          let address = try self.xmtpConnector.address()
          await send(.dismissAndOpenConversation(conversation, address))
        }
        
      case .dismissAndOpenConversation:
        // Handled by parent
        return .none
    }
  }
}

struct CreateConversationView: View {
  let store: Store<CreateConversation.State, CreateConversation.Action>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        VStack(spacing: 15) {
          HStack {
            Button("Cancel") { viewStore.send(.dismiss) }
            Spacer()
          }
          
          SearchBarView(
            searchText: viewStore.binding(
              get: \.searchText,
              send: CreateConversation.Action.updateSearchText
            )
          )
        }
        .frame(height: 80)
        .padding()
        .background { Theme.Color.greyShade1 }
        
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
        
        Spacer()
      }
    }
  }
}

struct SearchBarView: View {
  @Binding var searchText: String
  
  var body: some View {
    ZStack {
      Rectangle()
        .foregroundColor(
          Theme.Color.greyShade3
            .opacity(0.12)
        )
      HStack {
        Image(systemName: "magnifyingglass")
        TextField("Search for profile handles ...", text: $searchText)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)
      }
      .foregroundColor(Theme.Color.greyShade3)
      .padding(.leading, 10)
    }
    .frame(height: 40)
    .cornerRadius(Theme.defaultRadius)
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
