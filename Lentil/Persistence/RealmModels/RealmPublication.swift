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
  @Persisted var relatedPublication: RealmPublication?
  @Persisted var relatedProfile: RealmProfile?
  
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
  
  @Persisted var showsInFeed: Bool
  
  convenience init(id: String, typename: Typename, relatedPublication: RealmPublication? = nil, relatedProfile: RealmProfile? = nil, createdAt: Date, content: String, userProfile: RealmProfile, upvotes: Int, collects: Int, comments: Int, mirrors: Int, upvotedByUser: Bool, collectdByUser: Bool, commentdByUser: Bool, mirrordByUser: Bool, showsInFeed: Bool) {
    self.init()
    
    self.id = id
    self.typename = typename
    self.relatedPublication = relatedPublication
    self.relatedProfile = relatedProfile
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
    self.showsInFeed = showsInFeed
  }
}


extension RealmPublication {
  func publication() -> Model.Publication? {
    let typename: Model.Publication.Typename
    switch self.typename {
      case .post:
        typename = .post
        
      case .comment:
        guard let relatedPublication
        else {
          log("Publication with id \(self.id) is of type comment, but does not have a related publication", level: .error)
          return nil
        }
        typename = .comment(of: relatedPublication.publication())
        
      case .mirror:
        guard let relatedProfile
        else {
          log("Publication with id \(self.id) is of type mirror, but does not have a related profile", level: .error)
          return nil
        }
        typename = .mirror(by: relatedProfile.profile())
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
      mirrordByUser: self.mirrordByUser
    )
  }
}
