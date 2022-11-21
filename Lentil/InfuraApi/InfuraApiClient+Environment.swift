// Lentil
// Created by Laura and Cordt Zermin

import Dependencies


extension InfuraApi: DependencyKey {
  static let liveValue = InfuraApi(
    uploadText: { textFile in
      try await InfuraApi.upload(file: textFile)
    },
    uploadImage: { imageFile in
      try await InfuraApi.upload(file: imageFile)
    }
  )
  
#if DEBUG
  static let previewValue = InfuraApi(
    uploadText: { _ in InfuraApi.InfuraIPFSResponse(Name: "Lentil", Hash: "abc123", Size: "123456") },
    uploadImage: { _ in InfuraApi.InfuraIPFSResponse(Name: "Lentil", Hash: "abc123", Size: "123456") }
  ) 
#endif
}

extension DependencyValues {
  var infuraApi: InfuraApi {
    get { self[InfuraApi.self] }
    set { self[InfuraApi.self] = newValue }
  }
}
