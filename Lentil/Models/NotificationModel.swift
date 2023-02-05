// Lentil

import Foundation


//extension Model {
//  struct Notification: Equatable {
//    enum NotificationType: String, Equatable {
//      case mirroredPost = "MIRRORED_POST"
//      case mirroredComment = "MIRRORED_COMMENT"
//      case mentionPost = "MENTION_POST"
//      case mentionComment = "MENTION_COMMENT"
//      case commentedComment = "COMMENTED_COMMENT"
//      case commentedPost = "COMMENTED_POST"
//      case collectedPost = "COLLECTED_POST"
//      case collectedComment = "COLLECTED_COMMENT"
//      case followed = "FOLLOWED"
//      case reactionPost = "REACTION_POST"
//      case reactionComment = "REACTION_COMMENT"
//    }
//    
//    enum Event: Equatable {
//      enum Item: Equatable {
//        case post(_ id: String)
//        case comment(_ id: String)
//        case mirror(_ id: String)
//        
//        var name: String {
//          switch self {
//            case .post:     return "post"
//            case .comment:  return "comment"
//            case .mirror:   return "mirror"
//          }
//        }
//      }
//      case followed(_ by: String)
//      case collected(_ item: Item)
//      case commented(_ on: Item, _ with: Item)
//      case mirrored(_ item: Item)
//      case mentioned(_ in: Item)
//      case reacted(_ to: Item)
//    }
//    var id: String
//    var event: Event
//    var createdAt: Date
//    var profile: Model.Profile
//  }
//}
//
//#if DEBUG
//extension MockData {
//  static let mockNotifications: [Model.Notification] = [
//    .init(
//      id: "123-abc-def",
//      event: .followed("1"),
//      createdAt: Date().addingTimeInterval(-60 * 5),
//      profile: MockData.mockProfiles[0]
//    ),
//    .init(
//      id: "123-abc-ghi",
//      event: .collected(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
//      createdAt: Date().addingTimeInterval(-60 * 10),
//      profile: MockData.mockProfiles[1]
//    ),
//    .init(
//      id: "123-abc-jkl",
//      event: .commented(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276"), .comment("e59233e2-3a9c-4648-86bd-8b38548f6de8")),
//      createdAt: Date().addingTimeInterval(-60 * 20),
//      profile: MockData.mockProfiles[1]
//    ),
//    .init(
//      id: "123-abc-mno",
//      event: .mirrored(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
//      createdAt: Date().addingTimeInterval(-60 * 60),
//      profile: MockData.mockProfiles[3]
//    ),
//    .init(
//      id: "123-abc-pqr",
//      event: .mentioned(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
//      createdAt: Date().addingTimeInterval(-60 * 60 * 12),
//      profile: MockData.mockProfiles[0]
//    ),
//    .init(
//      id: "123-abc-stu",
//      event: .reacted(.post("6797e4fd-0d8b-4ca0-b434-daf4acce2276")),
//      createdAt: Date().addingTimeInterval(-60 * 60 * 48),
//      profile: MockData.mockProfiles[1]
//    )
//  ]
//}
//#endif
