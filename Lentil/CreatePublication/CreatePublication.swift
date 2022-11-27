// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Foundation


struct CreatePublication: ReducerProtocol {
  struct State: Equatable {
    enum Reason: Equatable, Hashable {
      case creatingPost
      case replyingToPost(_ postId: String, _ of: String)
      case replyingToComment(_ commentId: String, _ of: String)
    }
    var navigationId: String
    var reason: Reason
    var publicationText: String = ""
    var isPosting: Bool = false
    
    var placeholder: String {
      switch self.reason {
        case .creatingPost:       return "Share your thoughts!"
        case .replyingToPost:     return "Share your reply!"
        case .replyingToComment:  return "Share your reply!"
      }
    }
  }
  
  enum Action: Equatable {
    case dismissView(_ txHash: String?)
    case publicationTextChanged(String)
    case didTapCancel
    case createPublication
    case createPublicationResponse(TaskResult<MutationResult<Result<RelayerResult, RelayErrorReasons>>>)
  }
  
  @Dependency(\.infuraApi) var infuraApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.uuid) var uuid
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .dismissView:
        self.navigationApi.remove(
          DestinationPath(
            navigationId: state.navigationId,
            destination: .createPublication(state.reason)
          )
        )
        return .none
      
      case .publicationTextChanged(let text):
        state.publicationText = text
        return .none
        
      case .didTapCancel:
        state.publicationText = ""
        return Effect(value: .dismissView(nil))
        
      case .createPublication:
        guard let userProfile = self.profileStorageApi.load()
        else { return .none}
        
        let name = "lentil-" + uuid.callAsFunction().uuidString
        let publicationUrl = URL(string: "https://lentilapp.xyz/publication/\(name)")
        var description: String
        if case .creatingPost = state.reason { description = "Post by \(userProfile.handle) via lentil" }
        else { description = "Comment by \(userProfile.handle) via lentil" }
        
        guard
          state.publicationText.trimmingCharacters(in: .whitespacesAndNewlines) != "",
          let publicationFile = PublicationFile(
            metadata: Metadata(
              version: .two,
              metadata_id: name,
              description: description,
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
        
        return .task { [state = state] in
          let infuraResult = try await self.infuraApi.uploadPublication(publicationFile)
          
          return await .createPublicationResponse(
            TaskResult {
              let contentUri = "ipfs://\(infuraResult.Hash)"
              switch state.reason {
                case .creatingPost:
                  return try await self.lensApi.createPost(userProfile.id, contentUri)
                case .replyingToPost(let postId, _):
                  return try await self.lensApi.createComment(userProfile.id, postId, contentUri)
                case .replyingToComment(let commentId, _):
                  return try await self.lensApi.createComment(userProfile.id, commentId, contentUri)
              }
            }
          )
        }
        
      case .createPublicationResponse(.success(let result)):
        switch result.data {
          case .success(let relayerResult):
            state.publicationText = ""
            state.isPosting = false
            log("Successfully created publication: Hash: \(relayerResult.txnHash), Id: \(relayerResult.txnId)", level: .info)
            return Effect(value: .dismissView(relayerResult.txnHash))
            
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
