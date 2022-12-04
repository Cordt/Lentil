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
      let url = URL(string: mediaFields.url.replacingOccurrences(of: "ipfs://", with: "https://infura-ipfs.io/ipfs/"))
    else { return nil }
    
    return Model.Media(
      mediaType: .image(mimeType),
      url: url
    )
  }
  
  static func media(from: [MetadataOutputFields.Medium]) -> [Model.Media] {
    let mediaModels = from.compactMap(medium(from:))
    mediaModels.forEach { mediaCache.updateOrAppend($0) }
    return mediaModels
  }
}
