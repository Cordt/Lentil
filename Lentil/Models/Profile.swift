// Lentil

import Foundation
import SwiftUI

struct Profile: Equatable {
  var id: String
  var name: String?
  var handle: String
  var isFollowedByMe: Bool
  var profilePictureUrl: URL
  
  var profilePictureColor: some View {
    profileGradient(from: self.handle)
  }
}


#if DEBUG
let mockProfiles: [Profile] = [
  .init(
    id: "1",
    name: "NIDAVELLiR",
    handle: "@nidavellir.lens",
    isFollowedByMe: false,
    profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmUv8ABqYwfAXrxHVzxJwaWNjPxCzGtFKPNcXHmHqN8ArQ")!
  ),
  .init(
    id: "2",
    name: "Nader Dabit",
    handle: "@nader.lens",
    isFollowedByMe: true,
    profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmVBfhfgfhGsRVxTNURVUgceqyzjdVe11ic5rCghmePuKX")!
  ),
  .init(
    id: "3",
    name: "cordt.eth",
    handle: "@cordtminzer.lens",
    isFollowedByMe: false,
    profilePictureUrl: URL(string: "https://cloudflare-ipfs.com/ipfs/QmaZdyGNxdM2AB37PXp4bUjF3Mc5VR33r8pwMqmJF3P6be/dev_6163.png")!
  ),
  .init(
    id: "4",
    name: nil,
    handle: "@naval.lens",
    isFollowedByMe: false,
    profilePictureUrl: URL(string: "https://lens.infura-ipfs.io/ipfs/QmVBfhfgfhGsRVxTNURVUgceqyzjdVe11ic5rCghmePuKX")!
  )
]
#endif
