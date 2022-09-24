// Lentil

import Foundation
import SwiftUI

struct Publication: Identifiable, Equatable {
  indirect enum Typename: Equatable {
    case post
    case comment(of: Publication)
    case mirror(of: Publication)
  }
  
  let id: String
  let typename: Typename
  
  let createdAt: Date
  let content: String
  
  let profileName: String?
  let profileHandle: String
  let profilePictureUrl: URL
  
  let upvotes: Int
  let downvotes: Int
  let collects: Int
  let comments: Int
  let mirrors: Int
}


#if DEBUG
fileprivate let posts: [Publication] = [
  .init(
    id: "6797e4fd-0d8b-4ca0-b434-daf4acce2276",
    typename: .post,
    createdAt: Date().addingTimeInterval(-60*3),
    content: "\n\nCommerce on the Internet has come to rely almost exclusively on financial institutions serving as trusted third parties to process electronic payments. While the system works well enough for most transactions, it still suffers from the inherent weaknesses of the trust based model.\nCompletely non-reversible transactions are not really possible, since financial institutions cannot avoid mediating disputes. The cost of mediation increases transaction costs, limiting the minimum practical transaction size and cutting off the possibility for small casual transactions, and there is a broader cost in the loss of ability to make non-reversible payments for nonreversible services.\n \n",
    profileName: mockProfiles[0].name,
    profileHandle: mockProfiles[0].handle,
    profilePictureUrl: mockProfiles[0].profilePictureUrl,
    upvotes: 15,
    downvotes: 5,
    collects: 16,
    comments: 1,
    mirrors: 1
  ),
  .init(
    id: "d80681f9-b301-443d-960b-0415a134e1e3",
    typename: .post,
    createdAt: Date().addingTimeInterval(-60*60),
    content: "When Satoshi Nakamoto first set the Bitcoin blockchain into motion in January 2009, he was simultaneously introducing two radical and untested concepts. The first is the \"bitcoin\", a decentralized peer-to-peer online currency that maintains a value without any backing, intrinsic value or central issuer. So far, the \"bitcoin\" as a currency unit has taken up the bulk of the public attention, both in terms of the political aspects of a currency without a central bank and its extreme upward and downward volatility in price.\n    However, there is also another, equally important, part to Satoshi's grand experiment: the concept of a proof of work-based blockchain to allow for public agreement on the order of transactions. Bitcoin as an application can be described as a first-to-file system: if one entity has 50 BTC, and simultaneously sends the same 50 BTC to A and to B, only the transaction that gets confirmed first will process",
    profileName: mockProfiles[1].name,
    profileHandle: mockProfiles[1].handle,
    profilePictureUrl: mockProfiles[1].profilePictureUrl,
    upvotes: 12,
    downvotes: 16,
    collects: 32,
    comments: 2,
    mirrors: 1
  ),
  .init(
    id: "ba13fa94-30f9-4b6e-84ce-85ce316c7f4e",
    typename: .post,
    createdAt: Date().addingTimeInterval(-60*60*24),
    content: "Avalanche is a high-performance, scalable, customizable, and secure blockchain platform. It targets three broad use cases:\n– Building application-specific blockchains, spanning permissioned (private) and permissionless (public) deployments.\n– Building and launching highly scalable and decentralized applications (Dapps).\n– Building arbitrarily complex digital assets with custom rules, covenants, and riders (smart assets).",
    profileName: mockProfiles[3].name,
    profileHandle: mockProfiles[3].handle,
    profilePictureUrl: mockProfiles[3].profilePictureUrl,
    upvotes: 255,
    downvotes: 15,
    collects: 12,
    comments: 0,
    mirrors: 0
  )
]
fileprivate let comments: [Publication] = [
  .init(
    id: "e59233e2-3a9c-4648-86bd-8b38548f6de8",
    typename: .comment(of: posts[0]),
    createdAt: Date().addingTimeInterval(-60*15),
    content: "Commerce on the Internet has come to rely almost exclusively on financial institutions serving as trusted third parties to process electronic payments. While the system works well enough for most transactions, it still suffers from the inherent weaknesses of the trust based model.\nCompletely non-reversible transactions are not really possible, since financial institutions cannot avoid mediating disputes. The cost of mediation increases transaction costs, limiting the minimum practical transaction size and cutting off the possibility for small casual transactions, and there is a broader cost in the loss of ability to make non-reversible payments for nonreversible services.",
    profileName: mockProfiles[1].name,
    profileHandle: mockProfiles[1].handle,
    profilePictureUrl: mockProfiles[1].profilePictureUrl,
    upvotes: 15,
    downvotes: 5,
    collects: 16,
    comments: 0,
    mirrors: 1
  ),
  .init(
    id: "d5260ad6-c81b-42a2-a32e-8e8c4d79d309",
    typename: .comment(of: posts[1]),
    createdAt: Date().addingTimeInterval(-60*60*2),
    content: "When Satoshi Nakamoto first set the Bitcoin blockchain into motion in January 2009, he was simultaneously introducing two radical and untested concepts. The first is the \"bitcoin\", a decentralized peer-to-peer online currency that maintains a value without any backing, intrinsic value or central issuer. So far, the \"bitcoin\" as a currency unit has taken up the bulk of the public attention, both in terms of the political aspects of a currency without a central bank and its extreme upward and downward volatility in price.\n    However, there is also another, equally important, part to Satoshi's grand experiment: the concept of a proof of work-based blockchain to allow for public agreement on the order of transactions. Bitcoin as an application can be described as a first-to-file system: if one entity has 50 BTC, and simultaneously sends the same 50 BTC to A and to B, only the transaction that gets confirmed first will process",
    profileName: mockProfiles[1].name,
    profileHandle: mockProfiles[1].handle,
    profilePictureUrl: mockProfiles[1].profilePictureUrl,
    upvotes: 12,
    downvotes: 16,
    collects: 32,
    comments: 0,
    mirrors: 0
  ),
  .init(
    id: "49bcc907-db93-469d-9ad1-794e7000b01d",
    typename: .comment(of: posts[1]),
    createdAt: Date().addingTimeInterval(-60*60*40),
    content: "Avalanche is a high-performance, scalable, customizable, and secure blockchain platform. It targets three broad use cases:\n– Building application-specific blockchains, spanning permissioned (private) and permissionless (public) deployments.\n– Building and launching highly scalable and decentralized applications (Dapps).\n– Building arbitrarily complex digital assets with custom rules, covenants, and riders (smart assets).",
    profileName: mockProfiles[0].name,
    profileHandle: mockProfiles[0].handle,
    profilePictureUrl: mockProfiles[0].profilePictureUrl,
    upvotes: 255,
    downvotes: 15,
    collects: 12,
    comments: 0,
    mirrors: 0
  )
]
fileprivate let mirrors: [Publication] = [
  .init(
    id: "9bbb256e-8238-45c6-94cc-885666bbea86",
    typename: .mirror(of: posts[0]),
    createdAt: Date().addingTimeInterval(-60*12),
    content: posts[0].content,
    profileName: mockProfiles[1].name,
    profileHandle: mockProfiles[1].handle,
    profilePictureUrl: mockProfiles[1].profilePictureUrl,
    upvotes: 44,
    downvotes: 4,
    collects: 0,
    comments: 0,
    mirrors: 0
  ),
  .init(
    id: "837fc510-7a41-426d-89d8-22ca094d513c",
    typename: .mirror(of: posts[1]),
    createdAt: Date().addingTimeInterval(-60*60*14),
    content: "When Satoshi Nakamoto first set the Bitcoin blockchain into motion in January 2009, he was simultaneously introducing two radical and untested concepts. The first is the \"bitcoin\", a decentralized peer-to-peer online currency that maintains a value without any backing, intrinsic value or central issuer. So far, the \"bitcoin\" as a currency unit has taken up the bulk of the public attention, both in terms of the political aspects of a currency without a central bank and its extreme upward and downward volatility in price.\n    However, there is also another, equally important, part to Satoshi's grand experiment: the concept of a proof of work-based blockchain to allow for public agreement on the order of transactions. Bitcoin as an application can be described as a first-to-file system: if one entity has 50 BTC, and simultaneously sends the same 50 BTC to A and to B, only the transaction that gets confirmed first will process",
    profileName: mockProfiles[2].name,
    profileHandle: mockProfiles[2].handle,
    profilePictureUrl: mockProfiles[2].profilePictureUrl,
    upvotes: 33,
    downvotes: 3,
    collects: 0,
    comments: 0,
    mirrors: 0
  ),
  .init(
    id: "bbb19c4f-2931-473e-b3f1-b98ee94d32a0",
    typename: .mirror(of: comments[0]),
    createdAt: Date().addingTimeInterval(-60*60*24*7),
    content: "Avalanche is a high-performance, scalable, customizable, and secure blockchain platform. It targets three broad use cases:\n– Building application-specific blockchains, spanning permissioned (private) and permissionless (public) deployments.\n– Building and launching highly scalable and decentralized applications (Dapps).\n– Building arbitrarily complex digital assets with custom rules, covenants, and riders (smart assets).",
    profileName: mockProfiles[0].name,
    profileHandle: mockProfiles[0].handle,
    profilePictureUrl: mockProfiles[0].profilePictureUrl,
    upvotes: 12,
    downvotes: 200,
    collects: 0,
    comments: 0,
    mirrors: 0
  )
]

let mockPublications: [Publication] = posts + comments + mirrors
#endif
