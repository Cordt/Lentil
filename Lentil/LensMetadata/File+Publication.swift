// Lentil
// Created by Laura and Cordt Zermin

import Foundation


struct PublicationFile: FormDataAppendable {
  var data: Data { self.encodedMetadata }
  var fileMimeType: String? { nil }
  
  let encodedMetadata: Data
  let name: String
  let fileName: String
  
  init?(metadata: Metadata, name: String) {
    let encoder = JSONEncoder()
    do {
      let encodedMetadata = try encoder.encode(metadata)
      let name = name
      self.encodedMetadata = encodedMetadata
      self.name = name
      self.fileName = name + ".json"
      
    } catch let error {
      log("Failed to encode Metadata for publication", level: .error, error: error)
      return nil
    }
  }
}
