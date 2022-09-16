// Lentil

import Foundation

struct Post: Identifiable, Equatable {
  let id: String
  let createdAt: Date
  
  let name: String
  let content: String
  
  let creatorProfile: Profile
}


#if DEBUG
let mockPosts: [Post] = [
  .init(
    id: "6797e4fd-0d8b-4ca0-b434-daf4acce2276",
    createdAt: Date(timeIntervalSince1970: 1662037200),
    name: "Bitcoin: A Peer-to-Peer Electronic Cash System",
    content: "Commerce on the Internet has come to rely almost exclusively on financial institutions serving as trusted third parties to process electronic payments. While the system works well enough for most transactions, it still suffers from the inherent weaknesses of the trust based model.\nCompletely non-reversible transactions are not really possible, since financial institutions cannot avoid mediating disputes. The cost of mediation increases transaction costs, limiting the minimum practical transaction size and cutting off the possibility for small casual transactions, and there is a broader cost in the loss of ability to make non-reversible payments for nonreversible services.",
    creatorProfile: mockProfiles[0]
  ),
  .init(
    id: "d80681f9-b301-443d-960b-0415a134e1e3",
    createdAt: Date(timeIntervalSince1970: 1662033600),
    name: "Ethereum: A Next-Generation Smart Contract and Decentralized Application Platform",
    content: "When Satoshi Nakamoto first set the Bitcoin blockchain into motion in January 2009, he was simultaneously introducing two radical and untested concepts. The first is the \"bitcoin\", a decentralized peer-to-peer online currency that maintains a value without any backing, intrinsic value or central issuer. So far, the \"bitcoin\" as a currency unit has taken up the bulk of the public attention, both in terms of the political aspects of a currency without a central bank and its extreme upward and downward volatility in price.\n    However, there is also another, equally important, part to Satoshi's grand experiment: the concept of a proof of work-based blockchain to allow for public agreement on the order of transactions. Bitcoin as an application can be described as a first-to-file system: if one entity has 50 BTC, and simultaneously sends the same 50 BTC to A and to B, only the transaction that gets confirmed first will process",
    creatorProfile: mockProfiles[1]
  ),
  .init(
    id: "ba13fa94-30f9-4b6e-84ce-85ce316c7f4e",
    createdAt: Date(timeIntervalSince1970: 1662030000),
    name: "Avalanche Platform",
    content: "Avalanche is a high-performance, scalable, customizable, and secure blockchain platform. It targets three broad use cases:\n– Building application-specific blockchains, spanning permissioned (private) and permissionless (public) deployments.\n– Building and launching highly scalable and decentralized applications (Dapps).\n– Building arbitrarily complex digital assets with custom rules, covenants, and riders (smart assets).",
    creatorProfile: mockProfiles[2]
  )
]
#endif
