// Lentil

import Foundation

extension Publication {
  static func from(_ item: ExplorePublicationsQuery.Data.ExplorePublication.Item) -> Self? {
    guard
      let postFields = item.asPost?.fragments.postFields,
      let content = postFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: postFields.createdAt),
      let profilePictureUrlString = postFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString)
    else { return nil }
    
    return Publication(
      id: postFields.id,
      typename: .post,
      createdAt: createdDate,
      content: content,
      profileName: postFields.profile.fragments.profileFields.name,
      profileHandle: postFields.profile.fragments.profileFields.handle,
      profilePictureUrl: profilePictureUrl,
      upvotes: 0,
      downvotes: 0,
      collects: postFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: postFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: postFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors
    )
  }
  
  static func from(_ item: PublicationsQuery.Data.Publication.Item, child of: Publication) -> Self? {
    guard
      let commentFields = item.asComment?.fragments.commentFields.fragments.commentBaseFields,
      let content = commentFields.metadata.fragments.metadataOutputFields.content,
      let createdDate = date(from: commentFields.createdAt),
      let profilePictureUrlString = commentFields.profile.fragments.profileFields.picture?.asMediaSet?.original.fragments.mediaFields.url,
      let profilePictureUrl = URL(string: profilePictureUrlString)
    else { return nil }
    
    return Publication(
      id: commentFields.id,
      typename: .comment(of: of),
      createdAt: createdDate,
      content: content,
      profileName: commentFields.profile.fragments.profileFields.name,
      profileHandle: commentFields.profile.fragments.profileFields.handle,
      profilePictureUrl: profilePictureUrl,
      upvotes: 0,
      downvotes: 0,
      collects: commentFields.stats.fragments.publicationStatsFields.totalAmountOfCollects,
      comments: commentFields.stats.fragments.publicationStatsFields.totalAmountOfComments,
      mirrors: commentFields.stats.fragments.publicationStatsFields.totalAmountOfMirrors
    )
  }
}
