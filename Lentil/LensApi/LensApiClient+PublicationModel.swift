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
  
  private static func publication(from post: PostFields, reaction: ReactionTypes?) -> Self? {
    guard
      let content = post.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: post.createdAt),
      let profilePictureUrlString = post.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
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
  
  private static func publication(from comment: CommentBaseFields, reaction: ReactionTypes?, child of: Model.Publication? = nil) -> Self? {
    guard
      let content = comment.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: comment.createdAt),
      let profilePictureUrlString = comment.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
    else { return nil }
    
    return commentFrom(
      commentFields: comment,
      child: of,
      content: content,
      createdDate: createdDate,
      profilePictureUrl: profilePictureUrl,
      upvotedByUser: reaction == .upvote,
      collectdByUser: comment.hasCollectedByMe,
      commentdByUser: false,
      mirrordByUser: false
    )
  }
  
  static func publication(from item: FeedQuery.Data.Feed.Item.Root, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields.fragments.commentBaseFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    else {
      return nil
    }
  }
  
  static func publication(from item: PublicationsQuery.Data.Publication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields.fragments.commentBaseFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    else {
      return nil
    }
  }
  
  static func publication(from item: ExplorePublicationsQuery.Data.ExplorePublication.Item, child of: Model.Publication? = nil) -> Self? {
    if let postFields = item.asPost?.fragments.postFields {
      return publication(from: postFields, reaction: item.asPost?.postReaction)
    }
    else if let commentFields = item.asComment?.fragments.commentFields.fragments.commentBaseFields {
      return publication(from: commentFields, reaction: item.asComment?.commentReaction, child: of)
    }
    else {
      return nil
    }
  }
}
