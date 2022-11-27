// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import Foundation


struct Timeline: ReducerProtocol {
  enum Destination: Equatable {
    case connectWallet
    case showProfile
  }
  
  struct State: Equatable {
    var userProfile: UserProfile? = nil
    var posts: IdentifiedArrayOf<Post.State> = []
    var cursorFeed: String?
    var cursorExplore: String?
    var indexingPost: Bool = false
    
    var destination: Destination?
    var connectWallet: Wallet.State = .init()
    var showProfile: Profile.State? = nil
  }
  
  enum Action: Equatable {
    enum ResponseType: Equatable {
      case explore, feed
    }
    case timelineAppeared
    case refreshFeed
    case fetchDefaultProfile
    case defaultProfileResponse(TaskResult<Model.Profile>)
    case fetchPublications
    case publicationResponse(Model.Publication?)
    case publicationsResponse(QueryResult<[Model.Publication]>, ResponseType)
    case loadMore
    
    case createPublicationTapped
    
    case connectWallet(Wallet.Action)
    case showProfile(Profile.Action)
    case post(id: Post.State.ID, action: Post.Action)
    
    case setDestination(Destination?)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.connectWallet, action: /Action.connectWallet) {
      Wallet()
    }
    
    Reduce { state, action in
      enum CancelFetchPublicationsID {}
      
      switch action {
        case .timelineAppeared:
          var effects: [EffectTask<Action>] = []
          state.userProfile = profileStorageApi.load()
          if state.userProfile != nil && state.showProfile == nil { effects.append(Effect(value: .fetchDefaultProfile)) }
          if state.posts.count == 0 { effects.append(Effect(value: .refreshFeed)) }
          return .merge(effects)
          
        case .refreshFeed:
          state.indexingPost = false
          state.cursorFeed = nil
          return .concatenate(
            .cancel(id: CancelFetchPublicationsID.self),
            .init(value: .fetchPublications)
          )
          
        case .fetchDefaultProfile:
          guard let userProfile = state.userProfile
          else { return .none }
          
          return .task {
            await .defaultProfileResponse(
              TaskResult {
                try await lensApi.defaultProfile(userProfile.address).data
              }
            )
          }
          
        case .defaultProfileResponse(let .success(defaultProfile)):
          state.showProfile = Profile.State(navigationId: self.uuid.callAsFunction().uuidString, profile: defaultProfile)
          return Effect(value: .showProfile(.remoteProfilePicture(.fetchImage)))
          
        case .defaultProfileResponse(let .failure(error)):
          log("Failed to load default profile for authenticated user", level: .error, error: error)
          return .none
          
        case .fetchPublications:
          return .run { [cursorFeed = state.cursorFeed, cursorExplore = state.cursorExplore, id = state.userProfile?.id] send in
            do {
              if let id {
                await send(.publicationsResponse(try await lensApi.feed(40, cursorFeed, id, .fetchIgnoringCacheData, id), .feed))
                await send(.publicationsResponse(try await lensApi.explorePublications(10, cursorExplore, .topCommented, [.post], .fetchIgnoringCacheData, id), .explore))
              }
              else {
                await send(.publicationsResponse(try await lensApi.explorePublications(50, cursorExplore, .topCommented, [.post], .fetchIgnoringCacheData, id), .explore))
              }
            } catch let error {
              log("Failed to load timeline", level: .error, error: error)
            }
          }
          .cancellable(id: CancelFetchPublicationsID.self)
          
        case .loadMore:
          return .concatenate(
            .cancel(id: CancelFetchPublicationsID.self),
            .init(value: .fetchPublications)
          )
          
        case .publicationResponse(let publication):
          state.indexingPost = false
          guard let publication else { return .none }
          
          let postState = Post.State(navigationId: uuid.callAsFunction().uuidString, post: .init(publication: publication))
          state.posts.insert(postState, at: 0)
          publicationsCache.updateOrAppend(publication)
          return .none
          
        case .publicationsResponse(let response, let responseType):
          response.data
            .filter { $0.typename == .post }
            .map { Post.State(navigationId: uuid.callAsFunction().uuidString, post: .init(publication: $0)) }
            .forEach { state.posts.updateOrAppend($0) }
          
          response.data
            .filter { $0.typename == .post }
            .forEach { publicationsCache.updateOrAppend($0) }
          
          response.data
            .filter {
              if case .comment = $0.typename { return true }
              else { return false }
            }
            .map { Comment.State(comment: .init(publication: $0)) }
            .forEach { commentState in
              if case .comment(let parent) = commentState.comment.publication.typename {
                guard let parent else { return }
                state.posts.updateOrAppend(
                  Post.State(
                    navigationId: uuid.callAsFunction().uuidString,
                    post: Publication.State(publication: parent),
                    comments: [commentState]
                  )
                )
              }
            }
          
          response.data
            .forEach { profilesCache.updateOrAppend($0.profile) }
          
          state.posts.sort { $0.post.publication.createdAt > $1.post.publication.createdAt }
          
          switch responseType {
            case .explore:
              state.cursorExplore = response.cursorToNext
            case .feed:
              state.cursorFeed = response.cursorToNext
          }
          return .none
          
        case .createPublicationTapped:
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .createPublication(.creatingPost)
            )
          )
          return .none
          
        case .connectWallet(let walletConnectAction):
          switch walletConnectAction {
            case .defaultProfileResponse(let defaultProfile):
              state.showProfile = Profile.State(navigationId: self.uuid.callAsFunction().uuidString, profile: defaultProfile)
              return Effect(value: .showProfile(.remoteProfilePicture(.fetchImage)))
              
            default:
              return .none
          }
          
        case .showProfile:
          return .none
          
        case .post:
          return .none
          
        case .setDestination(let destination):
          state.destination = destination
          return .none
      }
    }
    .ifLet(\.showProfile, action: /Action.showProfile) {
      Profile()
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
