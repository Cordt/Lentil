// Lentil

import Foundation
import RealmSwift


class RealmMedia: Object {
  enum MediaType: String, PersistableEnum {
    case image
    
    func modelMediaType(with mimeType: Model.Media.ImageMimeType) -> Model.Media.MediaType {
      switch self {
        case .image: return .image(mimeType)
      }
    }
  }
  
  enum ImageMimeType: String, PersistableEnum {
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case png = "image/png"
    case tiff = "image/tiff"
    case xMsBmp = "image/x-ms-bmp"
    case svgXml = "image/svg+xml"
    case webp = "image/webp"
    
    func modelMimeType() -> Model.Media.ImageMimeType {
      switch self {
        case .gif:    return .gif
        case .jpeg:   return .jpeg
        case .png:    return .png
        case .tiff:   return .tiff
        case .xMsBmp: return .xMsBmp
        case .svgXml: return .svgXml
        case .webp:   return .webp
      }
    }
  }
  
  @Persisted(primaryKey: true) var id: String = ""
  
  @Persisted var mediaType: MediaType = .image
  @Persisted var imageMimeType: ImageMimeType? = .jpeg
  
  var url: URL? { URL(string: self.id) }
  
  convenience init(id: String, mediaType: MediaType, imageMimeType: ImageMimeType?) {
    self.init()
    
    self.id = id
    self.mediaType = mediaType
    self.imageMimeType = imageMimeType
  }
}

extension RealmMedia {
  func media() -> Model.Media? {
    guard let url = self.url
    else {
      log("Failed to create URL from url string for media model", level: .error)
      return nil
    }
    guard let mimeType = self.imageMimeType?.modelMimeType()
    else {
      log("Failed to retrieve Mime Type from media model", level: .error)
      return nil
    }
    return Model.Media(
      mediaType: self.mediaType.modelMediaType(with: mimeType),
      url: url
    )
  }
}

