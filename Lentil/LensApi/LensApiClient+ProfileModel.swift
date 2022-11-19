// Lentil
// Created by Laura and Cordt Zermin

import Foundation


extension Model.Profile {
  static func from(_ profile: ProfileFields) -> Self {
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
      joinedDate: nil,
      isDefault: profile.isDefault
    )
  }
  
  static func from(_ profiles: ProfilesQuery.Data.Profile) -> [Self] {
    return profiles.items.compactMap { self.from($0.fragments.profileFields) }
  }
}
