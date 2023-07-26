// Lentil

import Foundation
import RealmSwift


class RealmPublication: Object {
  indirect enum Typename: String, PersistableEnum {
    case post
    case comment
    case mirror
  }
  
  @Persisted(primaryKey: true) var id: String
  
  @Persisted var typename: Typename
  @Persisted var parentPublication: RealmPublication?
  @Persisted var mirroringProfile: RealmProfile?
  
  @Persisted var createdAt: Date
  @Persisted var content: String
  
  @Persisted var userProfile: RealmProfile?
  
  @Persisted var upvotes: Int
  @Persisted var collects: Int
  @Persisted var comments: Int
  @Persisted var mirrors: Int
  
  @Persisted var upvotedByUser: Bool
  @Persisted var collectdByUser: Bool
  @Persisted var commentdByUser: Bool
  @Persisted var mirrordByUser: Bool
  
  @Persisted var media: List<RealmMedia>
  
  @Persisted var showsInFeed: Bool
  @Persisted var isIndexing: Bool
  
  convenience init(id: String, typename: Typename, parentPublication: RealmPublication? = nil, mirroringProfile: RealmProfile? = nil, createdAt: Date, content: String, userProfile: RealmProfile, upvotes: Int, collects: Int, comments: Int, mirrors: Int, upvotedByUser: Bool, collectdByUser: Bool, commentdByUser: Bool, mirrordByUser: Bool, media: [RealmMedia], showsInFeed: Bool, isIndexing: Bool) {
    self.init()
    
    self.id = id
    self.typename = typename
    self.parentPublication = parentPublication
    self.mirroringProfile = mirroringProfile
    self.createdAt = createdAt
    self.content = content
    self.userProfile = userProfile
    self.upvotes = upvotes
    self.collects = collects
    self.comments = comments
    self.mirrors = mirrors
    self.upvotedByUser = upvotedByUser
    self.collectdByUser = collectdByUser
    self.commentdByUser = commentdByUser
    self.mirrordByUser = mirrordByUser
    media.forEach { self.media.append($0) }
    self.showsInFeed = showsInFeed
    self.isIndexing = isIndexing
  }
}


extension RealmPublication {
  func publication() -> Model.Publication? {
    let typename: Model.Publication.Typename
    switch self.typename {
      case .post:
        typename = .post
        
      case .comment:
        let parent = parentPublication?.publication()
        typename = .comment(of: parent)
        if parent == nil { log("Publication with id \(self.id) is of type comment, but does not have a related publication", level: .debug) }
        
      case .mirror:
        guard let mirroringProfile
        else {
          log("Publication with id \(self.id) is of type mirror, but does not have a related profile", level: .error)
          return nil
        }
        typename = .mirror(by: mirroringProfile.profile())
    }
    
    guard let profile = self.userProfile?.profile()
    else {
      log("Could not retrieve profile for publication with id \(self.id)", level: .error)
      return nil
    }
    
    return Model.Publication(
      id: self.id,
      typename: typename,
      createdAt: self.createdAt,
      content: self.content,
      profile: profile,
      upvotes: self.upvotes,
      collects: self.collects,
      comments: self.comments,
      mirrors: self.mirrors,
      upvotedByUser: self.upvotedByUser,
      collectdByUser: self.collectdByUser,
      commentdByUser: self.commentdByUser,
      mirrordByUser: self.mirrordByUser,
      media: self.media.compactMap { $0.media() },
      showsInFeed: self.showsInFeed,
      isIndexing: self.isIndexing
    )
  }
}
