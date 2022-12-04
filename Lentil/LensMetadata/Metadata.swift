// Lentil
// Created by Laura and Cordt Zermin

import Foundation


struct Metadata: Codable, Equatable {
  enum ContentWarning: String, Codable, Equatable {
    case nsfw = "NSFW"
    case sensitive = "SENSITIVE"
    case spoiler = "SPOILER"
  }
  
  enum ContentFocus: String, Codable, Equatable {
    case video = "VIDEO"
    case image = "IMAGE"
    case article = "ARTICLE"
    case text_only = "TEXT_ONLY"
    case audio = "AUDIO"
    case link = "LINK"
    case embed = "EMBED"
  }
  
  enum Version: String, Codable, Equatable {
    case two = "2.0.0"
  }
  
  enum Locale: String, Codable, Equatable {
    case english = "en"
  }
  
  struct Attribute: Codable, Equatable {
    enum DisplayType: String, Codable, Equatable {
      case number
      case string
      case date
    }
    
    var displayType: DisplayType?
    var traitType: String?
    var value: String
  }
  
  struct Medium: Codable, Equatable {
    var item: String
    var type: ImageFile.ImageMimeType
    var altTag: String?
    var cover: String?
  }
  
  var version: Version
  var metadata_id: String
  var description: String
  var content: String?
  var locale: Locale
  var tags: [String]
  var contentWarning: ContentWarning?
  var mainContentFocus: ContentFocus
  var external_url: URL?
  var name: String
  var attributes: [Attribute]
  var image: String
  var imageMimeType: ImageFile.ImageMimeType
  var media: [Medium] = []
  var appId: String = LentilEnvironment.shared.lentilAppId
}
