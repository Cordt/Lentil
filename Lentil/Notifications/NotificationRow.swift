// Lentil

import ComposableArchitecture
import SwiftUI


struct NotificationRow: ReducerProtocol {
  struct State: Equatable, Identifiable {
    var id: Model.Notification.ID { self.notification.id }
    var notification: Model.Notification
  }
  
  enum Action: Equatable {
    enum LoadingFailure: String {
      case post, comment, profile
    }
    
    case didTapRow
    case loadPost(_ elementId: String)
    case postResponse(TaskResult<Model.Publication?>)
    case loadComment(_ elementId: String)
    case commentResponse(TaskResult<Model.Publication?>)
    case loadProfile(_ elementId: String)
    case profileResponse(TaskResult<Model.Profile?>)
    case handleFailure(LoadingFailure, _ error: String?)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .didTapRow:
          switch state.notification.event {
            case .followed(_):
              // FIXME: Needs Profile
              return .none
            case .collected(let item):
              return .send(.loadPost(item.elementId))
              
            case .commented(let item, _):
              return .send(.loadComment(item.elementId))
              
            case .mirrored(let item):
              return .send(.loadPost(item.elementId))
              
            case .mentioned(let item):
              return .send(.loadPost(item.elementId))
              
            case .reacted(let item):
              return .send(.loadPost(item.elementId))
          }
          
        case .loadPost(let elementId):
          if let post = self.cache.publication(elementId) {
            return .send(.postResponse(.success(post)))
          }
          else {
            return .task {
              await .postResponse(TaskResult { try await self.lensApi.publicationById(elementId) })
            }
          }
          
        case .postResponse(.success(let post)):
          guard let post
          else { return EffectTask.send(.handleFailure(.post, nil)) }
          
          self.cache.updateOrAppendPublication(post)
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .publication(post.id)
            )
          )
          return .none
          
        case .loadComment(let elementId):
          return .task {
            var comment = self.cache.publication(elementId)
            if comment == nil { comment = try await self.lensApi.publicationById(elementId) }
            
            guard case .comment(let parent) = comment?.typename, let parent
            else { return .handleFailure(.comment, "Failed to get parent publication from comment")}
            
            if let parent = self.cache.publication(parent.id) {
              return .commentResponse(TaskResult.success(parent))
            }
            else {
              return await .commentResponse(TaskResult { try await self.lensApi.publicationById(parent.id) })
            }
          }
          
        case .commentResponse(.success(let parent)):
          guard let parent
          else { return EffectTask.send(.handleFailure(.comment, nil)) }
          
          self.cache.updateOrAppendPublication(parent)
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .publication(parent.id)
            )
          )
          return .none
          
        case .loadProfile(let elementId):
          if let profile = self.cache.profileById(elementId) {
            return .send(.profileResponse(.success(profile)))
          }
          else {
            return .task {
              await .profileResponse(TaskResult { try await self.lensApi.profile(elementId) })
            }
          }
          
        case .profileResponse(.success(let profile)):
          guard let profile
          else { return EffectTask.send(.handleFailure(.profile, nil)) }
          
          self.cache.updateOrAppendProfile(profile)
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .profile(profile.id)
            )
          )
          return .none
          
        case .postResponse(.failure(let error)):
          return .send(.handleFailure(.post, error.localizedDescription))
          
        case .commentResponse(.failure(let error)):
          return .send(.handleFailure(.comment, error.localizedDescription))
          
        case .profileResponse(.failure(let error)):
          return .send(.handleFailure(.profile, error.localizedDescription))
          
        case .handleFailure:
          // Handled by parent
          return .none
      }
    }
  }
}
