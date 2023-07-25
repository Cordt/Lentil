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
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.uuid) var uuid
  
  var body: some Reducer<State, Action> {
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
          return .run { send in
            await send(.postResponse(TaskResult { try await self.cache.publication(elementId) }))
          }
          
        case .postResponse(.success(let post)):
          guard let post
          else { return Effect.send(.handleFailure(.post, nil)) }
          
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .publication(post.id)
            )
          )
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
          
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .publication(parent.id)
            )
          )
          return .none
          
        case .loadProfile(let elementId):
          return .run { send in
            await send(.profileResponse(TaskResult { try await self.cache.profile(elementId) }))
          }
          
        case .profileResponse(.success(let profile)):
          guard let profile
          else { return Effect.send(.handleFailure(.profile, nil)) }
          
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
