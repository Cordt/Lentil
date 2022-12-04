// Lentil
// Created by Laura and Cordt Zermin

import Foundation


struct PublicationFile: FormDataAppendable {
  var data: Data { self.encodedMetadata }
  var fileMimeType: String? { nil }
  
  let encodedMetadata: Data
  let name: String
  let fileName: String
  
  init(metadata: Metadata, name: String) throws {
    let encoder = JSONEncoder()
    let encodedMetadata = try encoder.encode(metadata)
    let name = name
    self.encodedMetadata = encodedMetadata
    self.name = name
    self.fileName = name + ".json"
  }
}
