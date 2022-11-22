// Lentil
// Created by Laura and Cordt Zermin

import Dependencies


extension InfuraApi: DependencyKey {
  static let liveValue = InfuraApi(
    uploadPublication: { publicationFile in
      try await InfuraApi.upload(file: publicationFile)
    },
    uploadImage: { imageFile in
      try await InfuraApi.upload(file: imageFile)
    }
  )
  
#if DEBUG
  static let previewValue = InfuraApi(
    uploadPublication: { _ in InfuraApi.InfuraIPFSResponse(Name: "Lentil", Hash: "abc123", Size: "123456") },
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
