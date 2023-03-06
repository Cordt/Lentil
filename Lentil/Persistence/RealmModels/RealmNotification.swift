// Lentil


import Foundation
import RealmSwift


class RealmNotification: Object {
  enum NotificationType: String, PersistableEnum {
    case mirroredPost = "MIRRORED_POST"
    case mirroredComment = "MIRRORED_COMMENT"
    case mentionPost = "MENTION_POST"
    case mentionComment = "MENTION_COMMENT"
    case commentedComment = "COMMENTED_COMMENT"
    case commentedPost = "COMMENTED_POST"
    case collectedPost = "COLLECTED_POST"
    case collectedComment = "COLLECTED_COMMENT"
    case followed = "FOLLOWED"
    case reactionPost = "REACTION_POST"
    case reactionComment = "REACTION_COMMENT"
  }
  
  @Persisted(primaryKey: true) var id: String
  @Persisted var notificationType: NotificationType
  @Persisted var relatedPublicationId: String?
  @Persisted var secondRelatedPublicationId: String?
  @Persisted var relatedProfileId: String?
  @Persisted var createdAt: Date
  @Persisted var profile: RealmProfile?
  
  convenience init(id: String, notificationType: NotificationType, relatedPublicationId: String? = nil, secondRelatedPublicationId: String? = nil, relatedProfileId: String? = nil, createdAt: Date, profile: RealmProfile) {
    precondition(relatedPublicationId != nil || relatedProfileId != nil, "Either a publication or a profile must be related to the notification")
    self.init()
    
    self.id = id
    self.notificationType = notificationType
    self.relatedPublicationId = relatedPublicationId
    self.secondRelatedPublicationId = secondRelatedPublicationId
    self.relatedProfileId = relatedProfileId
    self.createdAt = createdAt
    self.profile = profile
  }
}


extension RealmNotification {
  func notification() -> Model.Notification? {
    let event: Model.Notification.Event
    switch self .notificationType {
      case .mirroredPost:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .mirrored(.post(elementId))
      case .mirroredComment:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .mirrored(.comment(elementId))
      case .mentionPost:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .mentioned(.post(elementId))
      case .mentionComment:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .mentioned(.comment(elementId))
      case .commentedComment:
        guard let elementId = self.relatedPublicationId, let secondElementId = self.secondRelatedPublicationId
        else { return nil }
        event = .commented(.comment(elementId), .comment(secondElementId))
      case .commentedPost:
        guard let elementId = self.relatedPublicationId, let secondElementId = self.secondRelatedPublicationId
        else { return nil }
        event = .commented(.post(elementId), .comment(secondElementId))
      case .collectedPost:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .collected(.post(elementId))
      case .collectedComment:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .collected(.comment(elementId))
      case .followed:
        guard let elementId = self.relatedProfileId
        else { return nil }
        event = .followed(elementId)
      case .reactionPost:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .reacted(.post(elementId))
      case .reactionComment:
        guard let elementId = self.relatedPublicationId
        else { return nil }
        event = .reacted(.comment(elementId))
    }
    
    guard let profile = self.profile?.profile()
    else { return nil }
            
    return Model.Notification(
      id: self.id,
      event: event,
      createdAt: self.createdAt,
      profile: profile
    )
  }
}
