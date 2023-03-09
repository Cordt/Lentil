// Lentil

import Foundation
import RealmSwift


class RealmProfile: Object {
  @Persisted(primaryKey: true) var id: String = ""
  @Persisted var name: String? = nil
  @Persisted var handle: String = ""
  @Persisted var ownedBy: String = ""
  @Persisted var profilePictureUrl: String? = nil
  @Persisted var coverPictureUrl: String? = nil
  @Persisted var bio: String? = nil
  @Persisted var isFollowedByMe: Bool = false
  @Persisted var following: Int = 0
  @Persisted var followers: Int = 0
  @Persisted var joinedDate: Date? = nil
  
  @Persisted var locationUrl: String? = nil
  @Persisted var twitterUrl: String? = nil
  @Persisted var websiteUrl: String? = nil
  
  @Persisted var isDefault: Bool
  
  
  convenience init(id: String, name: String? = nil, handle: String, ownedBy: String, profilePictureUrl: String? = nil, coverPictureUrl: String? = nil, bio: String? = nil, isFollowedByMe: Bool, following: Int, followers: Int, joinedDate: Date? = nil, locationUrl: String? = nil, twitterUrl: String? = nil, websiteUrl: String? = nil, isDefault: Bool) {
    self.init()
    
    self.id = id
    self.name = name
    self.handle = handle
    self.ownedBy = ownedBy
    self.profilePictureUrl = profilePictureUrl
    self.coverPictureUrl = coverPictureUrl
    self.bio = bio
    self.isFollowedByMe = isFollowedByMe
    self.following = following
    self.followers = followers
    self.joinedDate = joinedDate
    self.locationUrl = locationUrl
    self.twitterUrl = twitterUrl
    self.websiteUrl = websiteUrl
    self.isDefault = isDefault
  }
}


extension RealmProfile {
  func profile() -> Model.Profile {
    let profilePictureUrl: URL?
    let coverPictureUrl: URL?
    if let profilePictureUrlString = self.profilePictureUrl { profilePictureUrl = URL(string: profilePictureUrlString) }
    else { profilePictureUrl = nil }
    if let coverPictureUrlString = self.coverPictureUrl { coverPictureUrl = URL(string: coverPictureUrlString) }
    else { coverPictureUrl = nil }
    
    var attributes: [Model.Profile.Attribute] = []
    if let locationUrl = self.locationUrl { attributes.append(.init(key: .location, value: locationUrl)) }
    if let twitterUrl = self.twitterUrl { attributes.append(.init(key: .twitter, value: twitterUrl)) }
    if let websiteUrl = self.websiteUrl { attributes.append(.init(key: .website, value: websiteUrl)) }
    
    return Model.Profile(
      id: self.id,
      name: self.name,
      handle: self.handle,
      ownedBy: self.ownedBy,
      profilePictureUrl: profilePictureUrl,
      coverPictureUrl: coverPictureUrl,
      bio: self.bio,
      isFollowedByMe: self.isFollowedByMe,
      following: self.following,
      followers: self.followers,
      joinedDate: self.joinedDate,
      attributes: attributes,
      isDefault: self.isDefault
    )
  }
}
