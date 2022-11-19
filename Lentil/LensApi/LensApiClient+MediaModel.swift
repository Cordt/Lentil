// Lentil
// Created by Laura and Cordt Zermin

import Foundation


extension Model.Media {
  private static func medium(from: MetadataOutputFields.Medium) -> Model.Media? {
    // NB: Currently only handling Images
    let mediaFields = from.original.fragments.mediaFields
    guard
      let mimeTypeString = mediaFields.mimeType,
      let mimeType = Model.Media.ImageMimeType(rawValue: mimeTypeString),
      let url = URL(string: mediaFields.url.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/"))
    else { return nil }
    
    return Model.Media(
      mediaType: .image(mimeType),
      url: url
    )
  }
  
  static func media(from: [MetadataOutputFields.Medium]) -> [Model.Media] {
    return from.compactMap(medium(from:))
  }
}
