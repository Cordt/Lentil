// Lentil

import Foundation
import RealmSwift
import UIKit


extension Cache {
  struct PublicationUploadRequest {
    enum PublicationType {
      case post
      case comment(parentPublication: Model.Publication)
      
      func typename() -> Model.Publication.Typename {
        switch self {
          case .post:
            return .post
          case .comment(parentPublication: let parent):
            return .comment(of: parent)
        }
      }
    }
    
    enum UploadMedia {
      case gif(Gif)
      case photo(UIImage)
    }
    
    struct Gif: Equatable {
      var previewURL: URL
      var displayURL: URL
    }
  }
  
  // MARK: Create
  
  @MainActor
  func createPublication(
    publicationType: PublicationUploadRequest.PublicationType,
    publicationText: String,
    userProfileId: String,
    userProfileAddress: String,
    uploadMedia: [PublicationUploadRequest.UploadMedia]
  ) async throws {
    
    let realm = try await Realm(configuration: Self.realmConfig)
    let userProfile: Model.Profile
    if let cacheProfile = realm.object(ofType: RealmProfile.self, forPrimaryKey: userProfileId) {
      userProfile = cacheProfile.profile()
    }
    else {
      userProfile = try await self.lensApi.defaultProfile(userProfileAddress)
      try realm.write { realm.add(userProfile.realmProfile()) }
    }
    
    let name = "lentil-" + uuid.callAsFunction().uuidString
    let publicationUrl = URL(string: "https://lentilapp.xyz/publication/\(name)")
    let description: String
    switch publicationType {
      case .post:     description = "Post by \(userProfile.handle) via lentil"
      case .comment:  description = "Comment by \(userProfile.handle) via lentil"
    }
    
    let media: [Metadata.Medium] = try await uploadMedia.asyncReduce([]) { partialResult, uploadMedia in
      switch uploadMedia {
        case .gif(let gif):
          return partialResult + [Metadata.Medium(item: gif.displayURL.absoluteString, type: .gif)]
          
        case .photo(let image):
          guard let imageData = image.imageData(for: .feed, and: .storage)
          else { return partialResult }
          let imageFile = ImageFile(imageData: imageData, mimeType: .jpeg)
          let infuraImageResult = try await self.infuraApi.uploadImage(imageFile)
          let contentUri = "ipfs://\(infuraImageResult.Hash)"
          return partialResult + [Metadata.Medium(item: contentUri, type: .jpeg)]
      }
    }
    
    let modelMedia: [Model.Media] = media.compactMap { medium in
      guard let url = URL(string: medium.item)
      else { return nil }
      let mimeType: Model.Media.ImageMimeType
      switch medium.type {
        case .gif:    mimeType = .gif
        case .jpeg:   mimeType = .jpeg
        case .png:    mimeType = .png
        case .tiff:   mimeType = .tiff
        case .xMsBmp: mimeType = .xMsBmp
        case .svgXml: mimeType = .svgXml
        case .webp:   mimeType = .webp
      }
      return Model.Media(mediaType: .image(mimeType), url: url)
    }
    
    let publicationFile = try PublicationFile(
      metadata: Metadata(
        version: .two,
        metadata_id: name,
        description: description,
        content: publicationText,
        locale: .english,
        tags: [],
        contentWarning: nil,
        mainContentFocus: media.count > 0 ? .image : .text_only,
        external_url: publicationUrl,
        name: name,
        attributes: [],
        image: LentilEnvironment.shared.lentilIconIPFSUrl,
        imageMimeType: .jpeg,
        media: media,
        appId: LentilEnvironment.shared.lentilAppId
      ),
      name: name
    )
    
    let infuraPublicationResult = try await self.infuraApi.uploadPublication(publicationFile)
    let contentUri = "ipfs://\(infuraPublicationResult.Hash)"
    let publicationResult: Result<RelayerResult, RelayErrorReasons>
    switch publicationType {
      case .post:
        publicationResult = try await self.lensApi.createPost(userProfile.id, contentUri)
      case .comment(let parentPublication):
        publicationResult = try await self.lensApi.createComment(userProfile.id, parentPublication.id, contentUri)
    }
    
    switch publicationResult {
      case .success(let relayerResult):
        let publication = Model.Publication(
          id: relayerResult.txnHash,
          typename: publicationType.typename(),
          createdAt: Date(),
          content: publicationText,
          profile: userProfile,
          media: modelMedia,
          showsInFeed: true,
          isIndexing: true
        )
        try realm.write { realm.add(publication.realmPublication(), update: .modified) }
        log("Successfully created publication with txn hash: \(relayerResult.txnHash) and ID \(relayerResult.txnId)", level: .info)
        
        Task { await self.updateIndexingPublication(relayerResult: relayerResult) }
      
      case .failure(let errorReasons):
        log("Failed to create publication", level: .error, error: errorReasons)
    }
  }
  
  
  // MARK: Helper
  
  private func updateIndexingPublication(relayerResult: RelayerResult) async {
    do {
      var attempts = 5
      while attempts > 0 {
        if var publication = try await self.lensApi.publicationByHash(relayerResult.txnHash) {
          publication.showsInFeed = true
          Task { @MainActor [publication] in
            let realm = try Realm(configuration: Self.realmConfig)
            guard let indexingPublication = realm.object(ofType: RealmPublication.self, forPrimaryKey: relayerResult.txnHash)
            else { return }
            try realm.write {
              realm.delete(indexingPublication)
              realm.add(publication.realmPublication(), update: .modified)
            }
          }
          return
        }
        try await self.clock.sleep(for: .seconds(5))
        attempts -= 1
      }
      log("Failed to load recently created publication for TX Hash after 5 retries \(relayerResult.txnHash)", level: .warn)
      
    } catch let error {
      log("Failed to load recently created publication for TX Hash \(relayerResult.txnHash)", level: .error, error: error)
    }
  }
}
