// Lentil

import Foundation


extension Model.Notification {
  static func from(_ notification: NotificationsQuery.Data.Result.Item) -> Model.Notification? {
    let notificationID: String
    let event: Event
    let createdAt: Date
    let profile: Model.Profile
    
    if let typedNotification = notification.asNewCollectNotification {
      notificationID = typedNotification.notificationId
      guard let date = date(from: typedNotification.fragments.newCollectNotificationFields.createdAt)
      else { return nil }
      createdAt = date
      if let compactProfile = typedNotification.fragments.newCollectNotificationFields.wallet.fragments.userWallet.defaultProfile?.fragments.compactProfile {
        profile = Model.Profile.from(compactProfile)
      }
      else { return nil }
      
      if let post = typedNotification.fragments.newCollectNotificationFields.collectedPublication.asPost {
        event = .collected(.post(post.fragments.compactPost.id))
      }
      else if let comment = typedNotification.fragments.newCollectNotificationFields.collectedPublication.asComment {
        event = .collected(.comment(comment.fragments.compactComment.id))
      }
      else if let mirror = typedNotification.fragments.newCollectNotificationFields.collectedPublication.asMirror {
        event = .collected(.mirror(mirror.fragments.compactMirror.id))
      }
      else { return nil }
      
    }
    else if let typedNotification = notification.asNewCommentNotification {
      notificationID = typedNotification.notificationId
      guard let date = date(from: typedNotification.fragments.newCommentNotificationFields.createdAt)
      else { return nil }
      createdAt = date
      profile = Model.Profile.from(typedNotification.fragments.newCommentNotificationFields.profile.fragments.compactProfile)
      
      let commentedOn = typedNotification.fragments.newCommentNotificationFields.comment.fragments.commentWithCommentedPublicationFields.commentOn
      let commentedWith = typedNotification.fragments.newCommentNotificationFields.comment.fragments.commentWithCommentedPublicationFields.fragments.compactComment
      if let post = commentedOn?.asPost {
        event = .commented(.post(post.fragments.compactPost.id), .comment(commentedWith.id))
      }
      else if let comment = commentedOn?.asComment {
        event = .commented(.comment(comment.fragments.compactComment.id), .comment(commentedWith.id))
      }
      else if let mirror = commentedOn?.asMirror {
        event = .commented(.mirror(mirror.fragments.compactMirror.id), .comment(commentedWith.id))
      }
      else { return nil }
    }
    else if let typedNotification = notification.asNewFollowerNotification {
      notificationID = typedNotification.notificationId
      guard let date = date(from: typedNotification.fragments.newFollowerNotificationFields.createdAt)
      else { return nil }
      createdAt = date
      if let compactProfile = typedNotification.fragments.newFollowerNotificationFields.wallet.fragments.userWallet.defaultProfile?.fragments.compactProfile {
        event = .followed(compactProfile.handle)
        profile = Model.Profile.from(compactProfile)
      }
      else { return nil }
    }
    else if let typedNotification = notification.asNewMentionNotification {
      notificationID = typedNotification.notificationId
      guard let date = date(from: typedNotification.fragments.newMentionNotificationFields.createdAt)
      else { return nil }
      createdAt = date
      
      let mentionPublication = typedNotification.fragments.newMentionNotificationFields.mentionPublication
      if let post = mentionPublication.asPost {
        event = .mentioned(.post(post.fragments.compactPost.id))
        profile = Model.Profile.from(post.fragments.compactPost.profile.fragments.compactProfile)
      }
      else if let comment = mentionPublication.asComment {
        event = .mentioned(.comment(comment.fragments.compactComment.id))
        profile = Model.Profile.from(comment.fragments.compactComment.profile.fragments.compactProfile)
      }
      else { return nil }
    }
    else if let typedNotification = notification.asNewMirrorNotification {
      notificationID = typedNotification.notificationId
      guard let date = date(from: typedNotification.fragments.newMirrorNotificationFields.createdAt)
      else { return nil }
      createdAt = date
      
      let mirroredPublication = typedNotification.fragments.newMirrorNotificationFields.publication
      if let post = mirroredPublication.asPost {
        event = .mirrored(.post(post.fragments.compactPost.id))
        profile = Model.Profile.from(typedNotification.fragments.newMirrorNotificationFields.profile.fragments.compactProfile)
      }
      else if let comment = mirroredPublication.asComment {
        event = .mirrored(.comment(comment.fragments.compactComment.id))
        profile = Model.Profile.from(typedNotification.fragments.newMirrorNotificationFields.profile.fragments.compactProfile)
      }
      else { return nil }
    }
    else if let typedNotification = notification.asNewReactionNotification {
      notificationID = typedNotification.notificationId
      guard let date = date(from: typedNotification.fragments.newReactionNotificationFields.createdAt)
      else { return nil }
      createdAt = date
      
      let reactedPublication = typedNotification.fragments.newReactionNotificationFields.publication
      if let post = reactedPublication.asPost {
        event = .reacted(.post(post.fragments.compactPost.id))
        profile = Model.Profile.from(typedNotification.fragments.newReactionNotificationFields.profile.fragments.compactProfile)
      }
      else if let comment = reactedPublication.asComment {
        event = .reacted(.comment(comment.fragments.compactComment.id))
        profile = Model.Profile.from(typedNotification.fragments.newReactionNotificationFields.profile.fragments.compactProfile)
      }
      else { return nil }
    }
    else { return nil }
    
    return Model.Notification(
      id: notificationID,
      event: event,
      createdAt: createdAt,
      profile: profile
    )
  }
}
