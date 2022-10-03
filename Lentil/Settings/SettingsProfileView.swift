// Lentil

import ComposableArchitecture
import SwiftUI

struct SettingsProfileView: View {
  let store: Store<SettingsProfileState, SettingsProfileAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      Section(
        header: Text("Profile"),
        footer: Text("Your wallet can hold any number of profile NFTs. The default profile is the one that will be used for interacting with Lens Protocol.")
      ) {
        if let profileName = viewStore.profile.name {
          HStack {
            Text("Name: \(profileName)")
            Spacer()
            Button("Edit") { }
          }
        }
        else {
          HStack {
            Text("Profile name not set")
              .italic()
            Spacer()
            Button("Set") { }
            .buttonStyle(.borderless)
          }
        }
        Text("Handle: \(viewStore.profile.handle)")
      }
      .tint(ThemeColor.primaryRed.color)
    }
  }
}

struct SettingsProfileView_Previews: PreviewProvider {
  static var previews: some View {
    Form {
      SettingsProfileView(
        store: .init(
          initialState: .init(profile: mockProfiles[2]),
          reducer: settingsProfileReducer,
          environment: ()
        )
      )
      
      SettingsProfileView(
        store: .init(
          initialState: .init(profile: mockProfiles[3]),
          reducer: settingsProfileReducer,
          environment: ()
        )
      )
    }
  }
}
