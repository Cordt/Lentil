// Lentil
// Created by Laura and Cordt Zermin

import Foundation

extension Model.Publication {
  private static func postFrom(
    postFields: PostFields,
    content: String,
    createdDate: Date,
    profilePictureUrl: URL,
    upvotedByUser: Bool,
    collectdByUser: Bool,
    commentdByUser: Bool,
    mirrordByUser: Bool
  ) -> Self? {
    return Model.Publication(
      id: postFields.id,
      typename: .post,
      createdAt: createdDate,
      content: content,
      profileName: postFields.profile.fragments.profileFields.name,
      profileHandle: postFields.profile.fragments.profileFields.handle,
      profilePictureUrl: profilePictureUrl,
      upvotes: postFields.stats.fragments.publicationStatsFields.totalUpvotes,
      collects: postFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: postFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: postFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser
    )
  }
  
  private static func commentFrom(
    commentFields: CommentBaseFields,
    child of: Model.Publication?,
    content: String,
    createdDate: Date,
    profilePictureUrl: URL,
    upvotedByUser: Bool,
    collectdByUser: Bool,
    commentdByUser: Bool,
    mirrordByUser: Bool
  ) -> Self? {
    return Model.Publication(
      id: commentFields.id,
      typename: .comment(of: of),
      createdAt: createdDate,
      content: content,
      profileName: commentFields.profile.fragments.profileFields.name,
      profileHandle: commentFields.profile.fragments.profileFields.handle,
      profilePictureUrl: profilePictureUrl,
      upvotes: commentFields.stats.fragments.publicationStatsFields.totalUpvotes,
      collects: commentFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: commentFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: commentFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser
    )
  }
  
  static func media() {
//    item.asPost?.fragments.postFields.metadata.fragments.metadataOutputFields.media.first?.original.fragments.mediaFields
  }
  
  static func publication(from item: PublicationsQuery.Data.Publication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      guard
        let content = postFields.metadata.fragments.metadataOutputFields.content,
        let createdDate = date(from: postFields.createdAt),
        let profilePictureUrlString = postFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
        let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/"))
      else { return nil }
      
      return postFrom(
        postFields: postFields,
        content: content,
        createdDate: createdDate,
        profilePictureUrl: profilePictureUrl,
        upvotedByUser: item.asPost?.postReaction == .upvote,
        collectdByUser: postFields.hasCollectedByMe,
        commentdByUser: false,
        mirrordByUser: false
      )
    }
    else if let commentFields = item.asComment?.fragments.commentFields.fragments.commentBaseFields {
      guard
        let content = commentFields.metadata.fragments.metadataOutputFields.content,
        let createdDate = date(from: commentFields.createdAt),
        let profilePictureUrlString = commentFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
        let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/"))
      else { return nil }
      
      return commentFrom(
        commentFields: commentFields,
        child: of,
        content: content,
        createdDate: createdDate,
        profilePictureUrl: profilePictureUrl,
        upvotedByUser: item.asComment?.commentReaction == .upvote,
        collectdByUser: commentFields.hasCollectedByMe,
        commentdByUser: false,
        mirrordByUser: false
      )
    }
    else {
      return nil
    }
  }
  
  static func publication(from item: ExplorePublicationsQuery.Data.ExplorePublication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      guard
        let content = postFields.metadata.fragments.metadataOutputFields.content,
        let createdDate = date(from: postFields.createdAt),
        let profilePictureUrlString = postFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
        let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/"))
      else { return nil }
      
      return postFrom(
        postFields: postFields,
        content: content,
        createdDate: createdDate,
        profilePictureUrl: profilePictureUrl,
        upvotedByUser: item.asPost?.postReaction == .upvote,
        collectdByUser: postFields.hasCollectedByMe,
        commentdByUser: false,
        mirrordByUser: false
      )
    }
    else if let commentFields = item.asComment?.fragments.commentFields.fragments.commentBaseFields {
      guard
        let content = commentFields.metadata.fragments.metadataOutputFields.content,
        let createdDate = date(from: commentFields.createdAt),
        let profilePictureUrlString = commentFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
        let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/"))
      else { return nil }
      
      return commentFrom(
        commentFields: commentFields,
        child: of,
        content: content,
        createdDate: createdDate,
        profilePictureUrl: profilePictureUrl,
        upvotedByUser: item.asComment?.postReaction == .upvote,
        collectdByUser: commentFields.hasCollectedByMe,
        commentdByUser: false,
        mirrordByUser: false
      )
    }
    else {
      return nil
    }
  }
}

extension Model.Profile {
  static func from(_ profile: DefaultProfileQuery.Data.DefaultProfile?) -> Self? {
    guard
      let profile = profile?.fragments.profileFields,
      profile.isDefault
    else { return nil }
    
    let profilePictureURL = profile.picture?.asMediaSet?.original.fragments.mediaFields.url
    let coverPictureURL = profile.coverPicture?.asMediaSet?.original.fragments.mediaFields.url
    var profileUrl: URL? = nil
    var coverUrl: URL? = nil
    if let urlString = profilePictureURL { profileUrl = URL(string: urlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")) }
    if let urlString = coverPictureURL { coverUrl = URL(string: urlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")) }
    
    return Model.Profile(
      id: profile.id,
      name: profile.name,
      handle: profile.handle,
      ownedBy: profile.ownedBy,
      profilePictureUrl: profileUrl,
      coverPictureUrl: coverUrl,
      bio: profile.bio,
      isFollowedByMe: profile.isFollowedByMe,
      following: profile.stats.totalFollowing,
      followers: profile.stats.totalFollowers,
      location: nil,
      joinedDate: Date(),
      isDefault: profile.isDefault
    )
  }
  
  static func from(_ profiles: ProfilesQuery.Data.Profile) -> [Self] {
    return profiles.items.map { profile in
      let profile = profile.fragments.profileFields
      let profilePictureURL = profile.picture?.asMediaSet?.original.fragments.mediaFields.url
      let coverPictureURL = profile.coverPicture?.asMediaSet?.original.fragments.mediaFields.url
      var profileUrl: URL? = nil
      var coverUrl: URL? = nil
      if let urlString = profilePictureURL { profileUrl =  URL(string: urlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")) }
      if let urlString = coverPictureURL { coverUrl =  URL(string: urlString.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")) }
      
      return Model.Profile(
        id: profile.id,
        name: profile.name,
        handle: profile.handle,
        ownedBy: profile.ownedBy,
        profilePictureUrl: profileUrl,
        coverPictureUrl: coverUrl,
        bio: profile.bio,
        isFollowedByMe: profile.isFollowedByMe,
        following: profile.stats.totalFollowing,
        followers: profile.stats.totalFollowers,
        location: nil,
        joinedDate: Date(),
        isDefault: profile.isDefault
      )
    }
  }
}
