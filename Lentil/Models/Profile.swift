// Lentil

import Foundation
import SwiftUI

extension Model {
  struct Profile: Identifiable, Equatable {
    var id: String
    var name: String?
    var handle: String
    var ownedBy: String
    var isFollowedByMe: Bool
    var profilePictureUrl: URL?
    var isDefault: Bool
    
    var profilePictureColor: some View {
      profileGradient(from: self.handle)
    }
  }
}

#if DEBUG
let mockProfiles: [Model.Profile] = [
  .init(
    id: "1",
    name: "NIDAVELLiR",
    handle: "@nidavellir.lens",
    ownedBy: "0x823A234Df5d302bA0371f2859554f727875B6EA0",
    isFollowedByMe: false,
    profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmUv8ABqYwfAXrxHVzxJwaWNjPxCzGtFKPNcXHmHqN8ArQ")!,
    isDefault: false
  ),
  .init(
    id: "2",
    name: "Nader Dabit",
    handle: "@nader.lens",
    ownedBy: "0x2651Ef4b545831D4601A59cFfb18a86b337ea5F5",
    isFollowedByMe: true,
    profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmVBfhfgfhGsRVxTNURVUgceqyzjdVe11ic5rCghmePuKX")!,
    isDefault: false
  ),
  .init(
    id: "3",
    name: "Cordt",
    handle: "@cordt.lens",
    ownedBy: ProcessInfo.processInfo.environment["TEST_WALLET_PUBLIC_KEY"]!,
    isFollowedByMe: false,
    profilePictureUrl: URL(string: "https://cloudflare-ipfs.com/ipfs/QmaZdyGNxdM2AB37PXp4bUjF3Mc5VR33r8pwMqmJF3P6be/dev_6163.png")!,
    isDefault: true
  ),
  .init(
    id: "4",
    name: nil,
    handle: "@naval.lens",
    ownedBy: "0x9DD183EB4Cc8202239879e163e53578598030c7b",
    isFollowedByMe: false,
    profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmVBfhfgfhGsRVxTNURVUgceqyzjdVe11ic5rCghmePuKX")!,
    isDefault: false
  )
]
#endif
