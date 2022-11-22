// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import UIKit


struct ImageFile: FormDataAppendable {
  enum ImageMimeType: String, Codable, Equatable {
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case png = "image/png"
    case tiff = "image/tiff"
    case xMsBmp = "image/x-ms-bmp"
    case svgXml = "image/svg+xml"
    case webp = "image/webp"
  }
  
  var data: Data { self.image }
  var fileMimeType: String? { self.mimeType.rawValue }
  
  let image: Data
  let mimeType: ImageMimeType
  let name: String
  let fileName: String
  
  init(image: UIImage, mimeType: ImageMimeType) {
    let imageData = image.jpegData(compressionQuality: 0.75)!
    let name = "lentil-" + UUID().uuidString
    
    self.image = imageData
    self.mimeType = mimeType
    self.name = name
    self.fileName = name + ImageFile.fileExtension(for: mimeType)
  }
  
  private static func fileExtension(for mimeType: ImageMimeType) -> String {
    switch mimeType {
      case .gif:    return ".gif"
      case .jpeg:   return ".jpeg"
      case .png:    return ".png"
      case .tiff:   return ".tiff"
      case .xMsBmp: return ".xMsBmp"
      case .svgXml: return ".svgXml"
      case .webp:   return ".webp"
    }
  }
}
