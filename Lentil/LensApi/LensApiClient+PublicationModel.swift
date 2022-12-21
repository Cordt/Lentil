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
      profile: Model.Profile.from(postFields.profile.fragments.profileFields),
      upvotes: postFields.stats.fragments.publicationStatsFields.totalUpvotes,
      collects: postFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: postFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: postFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser,
      media: Model.Media.media(from: postFields.metadata.fragments.metadataOutputFields.media)
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
      profile: Model.Profile.from(commentFields.profile.fragments.profileFields),
      upvotes: commentFields.stats.fragments.publicationStatsFields.totalUpvotes,
      collects: commentFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: commentFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: commentFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser,
      media: Model.Media.media(from: commentFields.metadata.fragments.metadataOutputFields.media)
    )
  }
  
  private static func mirrorFrom(
    id: String,
    mirror by: Model.Profile,
    publication of: Model.Profile,
    content: String,
    createdDate: Date,
    profilePictureUrl: URL,
    publicationStatsFields: PublicationStatsFields,
    upvotedByUser: Bool,
    collectdByUser: Bool,
    commentdByUser: Bool,
    mirrordByUser: Bool,
    media: [MetadataOutputFields.Medium]
  ) -> Self? {
    
    return Model.Publication(
      id: id,
      typename: .mirror(by: by),
      createdAt: createdDate,
      content: content,
      profile: of,
      upvotes: publicationStatsFields.totalUpvotes,
      collects: publicationStatsFields.totalAmountOfCollects,
      comments: publicationStatsFields.totalAmountOfComments,
      mirrors: publicationStatsFields.totalAmountOfMirrors,
      upvotedByUser: upvotedByUser,
      collectdByUser: collectdByUser,
      commentdByUser: commentdByUser,
      mirrordByUser: mirrordByUser,
      media: Model.Media.media(from: media)
    )
  }
  
  private static func publication(from post: PostFields, reaction: ReactionTypes?) -> Self? {
    guard
      let content = post.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: post.createdAt),
      let profilePictureUrlString = post.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://lens.infura-ipfs.io/ipfs/"))
    else { return nil }
    
    return postFrom(
      postFields: post,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: reaction == .upvote,
      collectdByUser: post.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  private static func publication(from comment: CommentFields, reaction: ReactionTypes?, child of: Model.Publication? = nil) -> Self? {
    guard
      let content = comment.fragments.commentBaseFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: comment.fragments.commentBaseFields.createdAt),
      let profilePictureUrlString = comment.fragments.commentBaseFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://lens.infura-ipfs.io/ipfs/"))
    else { return nil }
    
    // If no parent is passed explicitly, check whether the query data contains one
    var parent: Model.Publication? = of
    if parent == nil, let parentPost = comment.mainPost.asPost {
      parent = publication(from: parentPost.fragments.postFields, reaction: parentPost.postReaction)
    }
    
    return commentFrom(
      commentFields: comment.fragments.commentBaseFields,
      child: parent,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: reaction == .upvote,
      collectdByUser: comment.fragments.commentBaseFields.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  private static func publication(from mirror: MirrorFields, reaction: ReactionTypes?) -> Self? {
    let profileFields: ProfileFields
    let publicationStatsFields: PublicationStatsFields
    if let mirroredPost = mirror.mirrorOf.asPost {
      profileFields = mirroredPost.fragments.postFields.profile.fragments.profileFields
      publicationStatsFields = mirroredPost.fragments.postFields.stats.fragments.publicationStatsFields
    }
    else if let mirroredComment = mirror.mirrorOf.asComment {
      profileFields = mirroredComment.fragments.commentFields.fragments.commentBaseFields.profile.fragments.profileFields
      publicationStatsFields = mirroredComment.fragments.commentFields.fragments.commentBaseFields.stats.fragments.publicationStatsFields
    }
    else { return nil }
    
    guard
      let content = mirror.fragments.mirrorBaseFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: mirror.fragments.mirrorBaseFields.createdAt),
      let profilePictureUrlString = profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://lens.infura-ipfs.io/ipfs/"))
    else { return nil }
    
    let mirroringProfile = Model.Profile.from(mirror.fragments.mirrorBaseFields.profile)
    let publicationAuthorProfile = Model.Profile.from(profileFields)
    
    return mirrorFrom(
      id: mirror.fragments.mirrorBaseFields.id,
      mirror: mirroringProfile,
      publication: publicationAuthorProfile,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      publicationStatsFields: publicationStatsFields,
      upvotedByUser: reaction == .upvote,
      collectdByUser: mirror.fragments.mirrorBaseFields.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false,
      media: mirror.fragments.mirrorBaseFields.metadata.fragments.metadataOutputFields.media
    )
  }
  
  static func publication(from item: FeedQuery.Data.Feed.Item, child of: Model.Publication? = nil) -> Self? {
    var pub: Model.Publication
    if let postFields = item.root.asPost?.fragments.postFields {
      guard let post = publication(from: postFields, reaction: item.root.asPost?.postReaction)
      else { return nil }
      pub = post
    }
    else if let commentFields = item.root.asComment?.fragments.commentFields {
      guard let comment = publication(from: commentFields, reaction: item.root.asComment?.commentReaction, child: of)
      else { return nil }
      pub = comment
    }
    else {
      return nil
    }
    
    if let mirror = item.mirrors.first {
      let mirrorer = Model.Profile.from(mirror.profile.fragments.profileFields)
      pub.typename = .mirror(by: mirrorer)
    }
    
    return pub
  }
  
  static func publication(from item: PublicationQuery.Data.Publication?) -> Self? {
    if let postFields = item?.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: nil)
    }
    else if let commentFields = item?.asComment?.fragments.commentFields {
      return publication(from: commentFields, reaction: item?.asComment?.commentReaction)
    }
    else if let mirrorFields = item?.asMirror?.fragments.mirrorFields {
      return publication(from: mirrorFields, reaction: item?.asMirror?.mirrorReaction)
    }
    else {
      return nil
    }
  }
  
  static func publication(from item: PublicationsQuery.Data.Publication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    else if let mirrorFields = item.asMirror?.fragments.mirrorFields {
      return publication(from: mirrorFields, reaction: item.asMirror?.mirrorReaction)
    }
    else {
      return nil
    }
  }
  
  static func publication(from item: ExplorePublicationsQuery.Data.ExplorePublication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    else if let mirrorFields = item.asMirror?.fragments.mirrorFields {
      return publication(from: mirrorFields, reaction: item.asMirror?.mirrorReaction)
    }
    else {
      return nil
    }
  }
}
