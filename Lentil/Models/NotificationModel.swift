// Lentil

import Foundation


extension Model {
  struct Notification: Equatable {
    enum NotificationType: String, Equatable {
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
    
    enum Event: Equatable {
      enum Item: Equatable {
        case post(_ id: String)
        case comment(_ id: String)
        case mirror(_ id: String)
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
    var profile: Model.Profile?
  }
}

#if DEBUG
extension MockData {
  static let mockNotifications: [Model.Notification] = [
    .init(
      id: "123-abc-def",
      event: .commented(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276"), .comment("e59233e2-3a9c-4648-86bd-8b38548f6de8")),
      createdAt: Date().addingTimeInterval(60 * 5)
    )
  ]
}
#endif
