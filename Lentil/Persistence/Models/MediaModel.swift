// Lentil
// Created by Laura and Cordt Zermin

import Foundation

extension Model {
  struct Media: Equatable, Identifiable {
    enum MediaType: Equatable {
      case image(ImageMimeType)
    }
    
    enum ImageMimeType: String {
      case gif = "image/gif"
      case jpeg = "image/jpeg"
      case png = "image/png"
      case tiff = "image/tiff"
      case xMsBmp = "image/x-ms-bmp"
      case svgXml = "image/svg+xml"
      case webp = "image/webp"
    }
    
    var id: String { self.url.absoluteString }
    
    let mediaType: MediaType
    let url: URL
  }
}
