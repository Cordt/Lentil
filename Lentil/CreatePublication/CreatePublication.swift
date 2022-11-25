// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Foundation


struct CreatePublication: ReducerProtocol {
  struct State: Equatable {
    var publicationText: String = ""
    var isPosting: Bool = false
  }
  
  enum Action: Equatable {
    case toggleView(_ active: Bool)
    case publicationTextChanged(String)
    case didTapCancel
    case createPublication
    case createPublicationResponse(TaskResult<MutationResult<Result<RelayerResult, RelayErrorReasons>>>)
  }
  
  @Dependency(\.infuraApi) var infuraApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .toggleView:
        // Allows the parent to dismiss this view
        return .none
      
      case .publicationTextChanged(let text):
        state.publicationText = text
        return .none
        
      case .didTapCancel:
        state.publicationText = ""
        return Effect(value: .toggleView(false))
        
      case .createPublication:
        let name = "lentil-" + UUID().uuidString
        let publicationUrl = URL(string: "https://lentilapp.xyz/publication/\(name)")
        
        guard
          state.publicationText.trimmingCharacters(in: .whitespacesAndNewlines) != "",
          let userProfile = self.profileStorageApi.load(),
          let publicationFile = PublicationFile(
            metadata: Metadata(
              version: .two,
              metadata_id: name,
              description: "Post by \(userProfile.handle) via lentil",
              content: state.publicationText,
              locale: .english,
              tags: [],
              contentWarning: nil,
              mainContentFocus: .text_only,
              external_url: publicationUrl,
              name: name,
              attributes: [],
              image: LentilEnvironment.shared.lentilIconIPFSUrl,
              imageMimeType: .jpeg,
              appId: LentilEnvironment.shared.lentilAppId
            ),
            name: name
          )
        else { return .none }
        
        state.isPosting = true
        
        return .task {
          let infuraResult = try await self.infuraApi.uploadPublication(publicationFile)
          
          return await .createPublicationResponse(
            TaskResult {
              let contentUri = "ipfs://\(infuraResult.Hash)"
              return try await self.lensApi.createPost(userProfile.id, contentUri)
            }
          )
        }
        
      case .createPublicationResponse(.success(let result)):
        switch result.data {
          case .success(let relayerResult):
            state.publicationText = ""
            state.isPosting = false
            log("Successfully created publication: Hash: \(relayerResult.txnHash), Id: \(relayerResult.txnId)", level: .info)
            return Effect(value: .toggleView(false))
            
          case .failure(let error):
            state.isPosting = false
            log("Failed to create publication", level: .error, error: error)
            return .none
        }
        
      case .createPublicationResponse(.failure(let error)):
        state.isPosting = false
        log("Failed to create publication", level: .error, error: error)
        return .none
    }
  }
}
