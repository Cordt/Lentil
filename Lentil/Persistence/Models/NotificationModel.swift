// Lentil

import Foundation


extension Model {
  struct Notification: ViewModel {
    enum Event: Equatable {
      enum Item: Equatable {
        case post(_ id: String)
        case comment(_ id: String)
        case mirror(_ id: String)
        
        var name: String {
          switch self {
            case .post:     return "post"
            case .comment:  return "comment"
            case .mirror:   return "mirror"
          }
        }
        
        var elementId: String {
          switch self {
            case .post(let elementId):    return elementId
            case .comment(let elementId): return elementId
            case .mirror(let elementId):  return elementId
          }
        }
      }
      case followed(_ by: String)
      case collected(_ item: Item)
      case commented(_ on: Item, _ with: Item)
      case mirrored(_ item: Item)
      case mentioned(_ in: Item)
      case reacted(_ to: Item)
    }
    var id: String
    var event: Event
    var createdAt: Date
    var profile: Model.Profile
  }
}

extension Model.Notification {
  func realmNotification() -> RealmNotification {
    var notificationType: RealmNotification.NotificationType = .reactionPost
    var relatedProfileId: String? = nil
    var relatedPublicationId: String? = nil
    var secondRelatedPublicationId: String? = nil
    
    switch self.event {
      case .followed(let profileId):
        notificationType = .followed
        relatedProfileId = profileId
      case .collected(let item):
        if case .post = item { notificationType = .collectedPost }
        if case .comment = item { notificationType = .collectedComment }
        relatedPublicationId = item.elementId
      case .commented(let firstItem, let secondItem):
        if case .post = firstItem { notificationType = .commentedPost }
        if case .comment = firstItem { notificationType = .commentedComment }
        relatedPublicationId = firstItem.elementId
        secondRelatedPublicationId = secondItem.elementId
      case .mirrored(let item):
        if case .post = item { notificationType = .mirroredPost }
        if case .comment = item { notificationType = .mirroredComment }
        relatedPublicationId = item.elementId
      case .mentioned(let item):
        if case .post = item { notificationType = .mentionPost }
        if case .comment = item { notificationType = .mentionComment }
        relatedPublicationId = item.elementId
      case .reacted(let item):
        if case .post = item { notificationType = .reactionPost }
        if case .comment = item { notificationType = .reactionComment }
        relatedPublicationId = item.elementId
    }
    return RealmNotification(
      id: self.id,
      notificationType: notificationType,
      relatedPublicationId: relatedPublicationId,
      secondRelatedPublicationId: secondRelatedPublicationId,
      relatedProfileId: relatedProfileId,
      createdAt: self.createdAt,
      profile: self.profile.realmProfile()
    )
  }
}

#if DEBUG
extension MockData {
  static let mockNotifications: [Model.Notification] = [
    .init(
      id: "123-abc-def",
      event: .followed("1"),
      createdAt: Date().addingTimeInterval(-60 * 5),
      profile: MockData.mockProfiles[0]
    ),
    .init(
      id: "123-abc-ghi",
      event: .collected(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
      createdAt: Date().addingTimeInterval(-60 * 10),
      profile: MockData.mockProfiles[1]
    ),
    .init(
      id: "123-abc-jkl",
      event: .commented(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276"), .comment("e59233e2-3a9c-4648-86bd-8b38548f6de8")),
      createdAt: Date().addingTimeInterval(-60 * 20),
      profile: MockData.mockProfiles[1]
    ),
    .init(
      id: "123-abc-mno",
      event: .mirrored(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
      createdAt: Date().addingTimeInterval(-60 * 60),
      profile: MockData.mockProfiles[3]
    ),
    .init(
      id: "123-abc-pqr",
      event: .mentioned(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
      createdAt: Date().addingTimeInterval(-60 * 60 * 12),
      profile: MockData.mockProfiles[0]
    ),
    .init(
      id: "123-abc-stu",
      event: .reacted(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
      createdAt: Date().addingTimeInterval(-60 * 60 * 48),
      profile: MockData.mockProfiles[1]
    )
  ]
}
#endif
