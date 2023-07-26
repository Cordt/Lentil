// Lentil

import ComposableArchitecture
import SwiftUI


struct NotificationRow: Reducer {
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
  @Dependency(\.navigate) var navigate
  @Dependency(\.uuid) var uuid
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .didTapRow:
          switch state.notification.event {
            case .followed(let id):
              self.navigate.navigate(.profile(id))
              
            case .collected(let item):
              self.navigate.navigate(.publication(item.elementId))
              
            case .commented(let item, _):
              self.navigate.navigate(.publication(item.elementId))
              
            case .mirrored(let item):
              self.navigate.navigate(.publication(item.elementId))
              
            case .mentioned(let item):
              self.navigate.navigate(.publication(item.elementId))
              
            case .reacted(let item):
              self.navigate.navigate(.publication(item.elementId))
          }
          return .none
          
        case .loadPost(let elementId):
          return .run { send in
            await send(.postResponse(TaskResult { try await self.cache.publication(elementId) }))
          }
          
        case .postResponse(.success(let post)):
          guard let post
          else { return Effect.send(.handleFailure(.post, nil)) }
          return .none
          
        case .loadComment(let elementId):
          return .run { send in
            let comment = try await self.cache.publication(elementId)
            
            guard case .comment(let parent) = comment?.typename, let parent
            else {
              await send(.handleFailure(.comment, "Failed to get parent publication from comment"))
              return
            }
            
            await send(.commentResponse(TaskResult.success(parent)))
          }
          
        case .commentResponse(.success(let parent)):
          guard let parent
          else { return Effect.send(.handleFailure(.comment, nil)) }
          return .none
          
        case .loadProfile(let elementId):
          return .run { send in
            await send(.profileResponse(TaskResult { try await self.cache.profile(elementId) }))
          }
          
        case .profileResponse(.success(let profile)):
          guard let profile
          else { return Effect.send(.handleFailure(.profile, nil)) }
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
