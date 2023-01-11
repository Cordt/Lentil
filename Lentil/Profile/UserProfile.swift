// Lentil
// Created by Laura and Cordt Zermin

import Foundation


struct UserProfile: DefaultsStorable, Equatable {
  static var profileKey: String = "user-profile"
  
  var id: String
  var handle: String
  var name: String?
  var address: String
}


#if DEBUG
extension MockData {
  static var mockUserProfile: UserProfile {
    UserProfile(
      id: "3",
      handle: "cordt.lens",
      name: "Cordt",
      address: LentilEnvironment.shared.testWalletAddress
    )
  }
}
#endif
