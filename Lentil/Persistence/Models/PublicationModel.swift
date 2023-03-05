// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import SwiftUI

struct Model {
  struct Publication: Identifiable, Equatable {
    indirect enum Typename: Equatable {
      case post
      case comment(of: Publication?)
      case mirror(by: Profile)
    }
    
    let id: String
    var typename: Typename
    
    let createdAt: Date
    let content: String
    
    var profile: Model.Profile
    
    var upvotes: Int
    var collects: Int
    var comments: Int
    var mirrors: Int
    
    var upvotedByUser: Bool
    var collectdByUser: Bool
    var commentdByUser: Bool
    var mirrordByUser: Bool
    
    var media: [Model.Media] = []
  }
}


extension Model.Publication {
  func realmPublication(showsInFeed: Bool) -> RealmPublication {
    let typename: RealmPublication.Typename
    let relatedPublication: RealmPublication?
    let relatedProfile: RealmProfile?
    switch self.typename {
      case .post:
        typename = .post
        relatedPublication = nil
        relatedProfile = nil
        
      case .comment(of: let of):
        typename = .comment
        relatedPublication = of?.realmPublication(showsInFeed: showsInFeed)
        relatedProfile = nil
        
      case .mirror(by: let by):
        typename = .mirror
        relatedPublication = nil
        relatedProfile = by.realmProfile()
    }
    
    return RealmPublication(
      id: self.id,
      typename: typename,
      relatedPublication: relatedPublication,
      relatedProfile: relatedProfile,
      createdAt: self.createdAt,
      content: self.content,
      userProfile: self.profile.realmProfile(),
      upvotes: self.upvotes,
      collects: self.collects,
      comments: self.comments,
      mirrors: self.mirrors,
      upvotedByUser: self.upvotedByUser,
      collectdByUser: self.collectdByUser,
      commentdByUser: self.commentdByUser,
      mirrordByUser: self.mirrordByUser,
      media: self.media.map { $0.realmMedia() },
      showsInFeed: showsInFeed
    )
  }
}

  
#if DEBUG
struct MockData {
  static let mockPosts: [Model.Publication] = [
    .init(
      id: "6797e4fd-0d8b-4ca0-b434-daf4acce2276",
      typename: .post,
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*38),
      content: "\n\nCommerce on the Internet has come to rely almost exclusively on financial institutions serving as trusted third parties to process electronic payments. While the system works well enough for most transactions, it still suffers from the inherent weaknesses of the trust based model.\nCompletely non-reversible transactions are not really possible, since financial institutions cannot avoid mediating disputes. The cost of mediation increases transaction costs, limiting the minimum practical transaction size and cutting off the possibility for small casual transactions, and there is a broader cost in the loss of ability to make non-reversible payments for nonreversible services.\n \n",
      profile: MockData.mockProfiles[0],
      upvotes: 15,
      collects: 16,
      comments: 1,
      mirrors: 1,
      upvotedByUser: false,
      collectdByUser: false,
      commentdByUser: false,
      mirrordByUser: false,
      media: [
        .init(mediaType: .image(.jpeg), url: URL(string: "https://feed-picture")!),
        .init(mediaType: .image(.jpeg), url: URL(string: "https://lentil-beta")!),
        .init(mediaType: .image(.jpeg), url: URL(string: "https://crete")!)
      ]
    ),
    .init(
      id: "d80681f9-b301-443d-960b-0415a134e1e3",
      typename: .post,
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*40),
      content: "When Satoshi Nakamoto first set the Bitcoin blockchain into motion in January 2009, he was simultaneously introducing two radical and untested concepts. The first is the \"bitcoin\", a decentralized peer-to-peer online currency that maintains a value without any backing, intrinsic value or central issuer. So far, the \"bitcoin\" as a currency unit has taken up the bulk of the public attention, both in terms of the political aspects of a currency without a central bank and its extreme upward and downward volatility in price.\n    However, there is also another, equally important, part to Satoshi's grand experiment: the concept of a proof of work-based blockchain to allow for public agreement on the order of transactions. Bitcoin as an application can be described as a first-to-file system: if one entity has 50 BTC, and simultaneously sends the same 50 BTC to A and to B, only the transaction that gets confirmed first will process",
      profile: MockData.mockProfiles[1],
      upvotes: 12,
      collects: 32,
      comments: 2,
      mirrors: 1,
      upvotedByUser: true,
      collectdByUser: false,
      commentdByUser: true,
      mirrordByUser: false,
      media: [Model.Media(mediaType: .image(.jpeg), url: URL(string: "https://feed-picture")!)]
    ),
    .init(
      id: "ba13fa94-30f9-4b6e-84ce-85ce316c7f4e",
      typename: .post,
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*42),
      content: "Avalanche is a high-performance, scalable, customizable, and secure blockchain platform. It targets three broad use cases:\n– Building application-specific blockchains, spanning permissioned (private) and permissionless (public) deployments.\n– Building and launching highly scalable and decentralized applications (Dapps).\n– Building arbitrarily complex digital assets with custom rules, covenants, and riders (smart assets).",
      profile: MockData.mockProfiles[3],
      upvotes: 255,
      collects: 12,
      comments: 0,
      mirrors: 0,
      upvotedByUser: false,
      collectdByUser: true,
      commentdByUser: false,
      mirrordByUser: true
    )
  ]
  static let mockComments: [Model.Publication] = [
    .init(
      id: "e59233e2-3a9c-4648-86bd-8b38548f6de8",
      typename: .comment(of: mockPosts[0]),
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*43),
      content: "Commerce on the Internet has come to rely almost exclusively on financial institutions serving as trusted third parties to process electronic payments. While the system works well enough for most transactions, it still suffers from the inherent weaknesses of the trust based model.\nCompletely non-reversible transactions are not really possible, since financial institutions cannot avoid mediating disputes. The cost of mediation increases transaction costs, limiting the minimum practical transaction size and cutting off the possibility for small casual transactions, and there is a broader cost in the loss of ability to make non-reversible payments for nonreversible services.",
      profile: MockData.mockProfiles[1],
      upvotes: 15,
      collects: 16,
      comments: 0,
      mirrors: 1,
      upvotedByUser: false,
      collectdByUser: true,
      commentdByUser: false,
      mirrordByUser: true
    ),
    .init(
      id: "d5260ad6-c81b-42a2-a32e-8e8c4d79d309",
      typename: .comment(of: mockPosts[1]),
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*44),
      content: "When Satoshi Nakamoto first set the Bitcoin blockchain into motion in January 2009, he was simultaneously introducing two radical and untested concepts. The first is the \"bitcoin\", a decentralized peer-to-peer online currency that maintains a value without any backing, intrinsic value or central issuer. So far, the \"bitcoin\" as a currency unit has taken up the bulk of the public attention, both in terms of the political aspects of a currency without a central bank and its extreme upward and downward volatility in price.\n    However, there is also another, equally important, part to Satoshi's grand experiment: the concept of a proof of work-based blockchain to allow for public agreement on the order of transactions. Bitcoin as an application can be described as a first-to-file system: if one entity has 50 BTC, and simultaneously sends the same 50 BTC to A and to B, only the transaction that gets confirmed first will process",
      profile: MockData.mockProfiles[1],
      upvotes: 12,
      collects: 32,
      comments: 0,
      mirrors: 0,
      upvotedByUser: true,
      collectdByUser: true,
      commentdByUser: false,
      mirrordByUser: false
    ),
    .init(
      id: "49bcc907-db93-469d-9ad1-794e7000b01d",
      typename: .comment(of: mockPosts[1]),
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*45),
      content: "Avalanche is a high-performance, scalable, customizable, and secure blockchain platform. It targets three broad use cases:\n– Building application-specific blockchains, spanning permissioned (private) and permissionless (public) deployments.\n– Building and launching highly scalable and decentralized applications (Dapps).\n– Building arbitrarily complex digital assets with custom rules, covenants, and riders (smart assets).",
      profile: MockData.mockProfiles[0],
      upvotes: 255,
      collects: 12,
      comments: 0,
      mirrors: 0,
      upvotedByUser: false,
      collectdByUser: false,
      commentdByUser: true,
      mirrordByUser: true
    )
  ]
  static let mockMirrors: [Model.Publication] = [
    .init(
      id: "9bbb256e-8238-45c6-94cc-885666bbea86",
      typename: .mirror(by: mockProfiles[0]),
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*46),
      content: mockPosts[0].content,
      profile: MockData.mockProfiles[1],
      upvotes: 44,
      collects: 0,
      comments: 0,
      mirrors: 0,
      upvotedByUser: false,
      collectdByUser: false,
      commentdByUser: false,
      mirrordByUser: false
    ),
    .init(
      id: "837fc510-7a41-426d-89d8-22ca094d513c",
      typename: .mirror(by: mockProfiles[1]),
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*47),
      content: "When Satoshi Nakamoto first set the Bitcoin blockchain into motion in January 2009, he was simultaneously introducing two radical and untested concepts. The first is the \"bitcoin\", a decentralized peer-to-peer online currency that maintains a value without any backing, intrinsic value or central issuer. So far, the \"bitcoin\" as a currency unit has taken up the bulk of the public attention, both in terms of the political aspects of a currency without a central bank and its extreme upward and downward volatility in price.\n    However, there is also another, equally important, part to Satoshi's grand experiment: the concept of a proof of work-based blockchain to allow for public agreement on the order of transactions. Bitcoin as an application can be described as a first-to-file system: if one entity has 50 BTC, and simultaneously sends the same 50 BTC to A and to B, only the transaction that gets confirmed first will process",
      profile: MockData.mockProfiles[2],
      upvotes: 33,
      collects: 0,
      comments: 0,
      mirrors: 0,
      upvotedByUser: false,
      collectdByUser: false,
      commentdByUser: false,
      mirrordByUser: false
    ),
    .init(
      id: "bbb19c4f-2931-473e-b3f1-b98ee94d32a0",
      typename: .mirror(by: mockProfiles[0]),
      createdAt: Date(timeIntervalSince1970: 60*60*24*365*48),
      content: "Avalanche is a high-performance, scalable, customizable, and secure blockchain platform. It targets three broad use cases:\n– Building application-specific blockchains, spanning permissioned (private) and permissionless (public) deployments.\n– Building and launching highly scalable and decentralized applications (Dapps).\n– Building arbitrarily complex digital assets with custom rules, covenants, and riders (smart assets).",
      profile: MockData.mockProfiles[0],
      upvotes: 12,
      collects: 0,
      comments: 0,
      mirrors: 0,
      upvotedByUser: false,
      collectdByUser: false,
      commentdByUser: false,
      mirrordByUser: false
    )
  ]
  
  static let mockPublications: [Model.Publication] = mockPosts + mockComments + mockMirrors
}
#endif
