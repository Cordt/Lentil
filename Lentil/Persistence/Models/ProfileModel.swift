// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import SwiftUI

extension Model {
  struct Profile: Presentable {
    struct Attribute: Equatable {
      enum Key: String {
        case location, twitter, website
      }
      var key: Key
      var value: String
    }
    var id: String
    var name: String?
    var handle: String
    var ownedBy: String
    var profilePictureUrl: URL?
    var coverPictureUrl: URL?
    var bio: String?
    var isFollowedByMe: Bool
    var following: Int
    var followers: Int
    var joinedDate: Date?
    var attributes: [Attribute]
    
    var isDefault: Bool
    
    var profilePictureColor: some View {
      profileGradient(from: self.handle)
    }
  }
}

extension Model.Profile {
  func realmProfile() -> RealmProfile {
    return RealmProfile(
      id: self.id,
      name: self.name,
      handle: self.handle,
      ownedBy: self.ownedBy,
      profilePictureUrl: self.profilePictureUrl?.absoluteString,
      coverPictureUrl: self.coverPictureUrl?.absoluteString,
      bio: self.bio,
      isFollowedByMe: self.isFollowedByMe,
      following: self.following,
      followers: self.followers,
      joinedDate: self.joinedDate,
      locationUrl: self.attributes.first(where: { $0.key == .location })?.value,
      twitterUrl: self.attributes.first(where: { $0.key == .twitter })?.value,
      websiteUrl: self.attributes.first(where: { $0.key == .website })?.value,
      isDefault: self.isDefault
    )
  }
}

#if DEBUG
extension MockData {
  static let mockProfiles: [Model.Profile] = [
    .init(
      id: "1",
      name: "NIDAVELLiR",
      handle: "nidavellir.lens",
      ownedBy: "0x823A234Df5d302bA0371f2859554f727875B6EA0",
      profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmUv8ABqYwfAXrxHVzxJwaWNjPxCzGtFKPNcXHmHqN8ArQ")!,
      coverPictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmUv8ABqYwfAXrxHVzxJwaWNjPxCzGtFKPNcXHmHqN8ArQ")!,
      bio: "love to eat and Bitcoin ⚡",
      isFollowedByMe: false,
      following: 142,
      followers: 12705,
      joinedDate: Date(timeIntervalSince1970: 957916800),
      attributes: [
        .init(key: .location, value: "The moon"),
        .init(key: .twitter, value: "nidavellir")
      ],
      isDefault: false
    ),
    .init(
      id: "2",
      name: "Nader Dabit",
      handle: "nader.lens",
      ownedBy: "0x2651Ef4b545831D4601A59cFfb18a86b337ea5F5",
      profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmVBfhfgfhGsRVxTNURVUgceqyzjdVe11ic5rCghmePuKX")!,
      coverPictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmUv8ABqYwfAXrxHVzxJwaWNjPxCzGtFKPNcXHmHqN8ArQ")!,
      bio: "Director of Developer Relations at @lensprotocol 🌿 & @aaveaave.lens 👻",
      isFollowedByMe: true,
      following: 142,
      followers: 12705,
      joinedDate: Date(timeIntervalSince1970: 957916800),
      attributes: [
        .init(key: .location, value: "The mars"),
        .init(key: .twitter, value: "dabit3")
      ],
      isDefault: false
    ),
    .init(
      id: "3",
      name: "Cordt",
      handle: "cordt.lens",
      ownedBy: LentilEnvironment.shared.testWalletAddress,
      profilePictureUrl: URL(string: "https://profile-picture")!,
      coverPictureUrl: URL(string: "https://cover-picture")!,
      bio: "I ELI5 Web3. But sometimes I’m the 5 year old.\nProduct at day, functional Swift at night.",
      isFollowedByMe: false,
      following: 142,
      followers: 12705,
      joinedDate: Date(timeIntervalSince1970: 957916800),
      attributes: [
        .init(key: .location, value: "It depends"),
        .init(key: .twitter, value: "cordtminzer"),
        .init(key: .website, value: "https://lentilapp.xyz")
      ],
      isDefault: true
    ),
    .init(
      id: "4",
      name: nil,
      handle: "naval.lens",
      ownedBy: "0x9DD183EB4Cc8202239879e163e53578598030c7b",
      profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmVBfhfgfhGsRVxTNURVUgceqyzjdVe11ic5rCghmePuKX")!,
      coverPictureUrl: URL(string: "https://cover-picture-2")!,
      bio: nil,
      isFollowedByMe: false,
      following: 142,
      followers: 12705,
      joinedDate: Date(timeIntervalSince1970: 957916800),
      attributes: [
        .init(key: .twitter, value: "navals")
      ],
      isDefault: false
    ),
  ]
}
#endif
