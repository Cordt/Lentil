// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture


struct CreatePublication: ReducerProtocol {
  struct State: Equatable {
    var publicationText: String = "This is a test text"
    var isPosting: Bool = false
  }
  
  enum Action: Equatable {
    case publicationTextChanged(String)
    case createPublication
    case createPublicationResponse(TaskResult<MutationResult<Result<RelayerResult, RelayErrorReasons>>>)
  }
  
  @Dependency(\.infuraApi) var infuraApi
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .publicationTextChanged(let text):
        state.publicationText = text
        return .none
        
      case .createPublication:
        guard
          state.publicationText.trimmingCharacters(in: .whitespacesAndNewlines) != "",
          let textFile = TextFile(text: state.publicationText),
          let userProfile = self.profileStorageApi.load()
        else { return .none }
        
        state.isPosting = true
        
        return .task {
          let infuraResult = try await self.infuraApi.uploadText(textFile)
          
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
            debugPrint(relayerResult)
            
          case .failure(let error):
            state.isPosting = false
            log("Failed to create publication", level: .error, error: error)
        }
        return .none
        
      case .createPublicationResponse(.failure(let error)):
        state.isPosting = false
        log("Failed to create publication", level: .error, error: error)
        return .none
    }
  }
}
