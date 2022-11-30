// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import Foundation


struct Timeline: ReducerProtocol {
  enum Destination: Equatable {
    case connectWallet
  }
  
  struct State: Equatable {
    enum ScrollPosition: Equatable {
      case top(_ navigationID: String)
    }
    var userProfile: UserProfile? = nil
    var posts: IdentifiedArrayOf<Post.State> = []
    var scrollPosition: ScrollPosition?
    var cursorFeed: String?
    var cursorExplore: String?
    var indexingPost: Bool = false
    var loadingInFlight: Bool = false
    
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
    case fetchingFailed
    
    case ownProfileTapped
    case lentilButtonTapped
    case createPublicationTapped
    case scrollAnimationFinished
    case scrollAnimationFinishedResult
    
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
          state.loadingInFlight = false
          state.cursorFeed = nil
          state.cursorExplore = nil
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
          profilesCache.updateOrAppend(defaultProfile)
          return Effect(value: .showProfile(.remoteProfilePicture(.fetchImage)))
          
        case .defaultProfileResponse(let .failure(error)):
          log("Failed to load default profile for authenticated user", level: .error, error: error)
          return .none
          
        case .fetchPublications:
          guard !state.loadingInFlight
          else { return .none }
          
          state.loadingInFlight = true
          return .run { [cursorFeed = state.cursorFeed, cursorExplore = state.cursorExplore, id = state.userProfile?.id] send in
            do {
              if let id {
                await send(.publicationsResponse(try await lensApi.feed(40, cursorFeed, id, .fetchIgnoringCacheData, id), .feed))
                await send(.publicationsResponse(try await lensApi.explorePublications(10, cursorExplore, .latest, [.post, .comment], .fetchIgnoringCacheData, id), .explore))
              }
              else {
                await send(.publicationsResponse(try await lensApi.explorePublications(50, cursorExplore, .latest, [.post, .comment], .fetchIgnoringCacheData, id), .explore))
              }
            } catch let error {
              await send(.fetchingFailed)
              log("Failed to load timeline", level: .error, error: error)
            }
          }
          .cancellable(id: CancelFetchPublicationsID.self)
          
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
            .map { Post.State(navigationId: uuid.callAsFunction().uuidString, post: .init(publication: $0)) }
            .forEach { commentState in
              if case .comment(let parent) = commentState.post.publication.typename {
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
          state.loadingInFlight = false
          return .none
          
        case .fetchingFailed:
          state.loadingInFlight = false
          return .none
          
        case .ownProfileTapped:
          guard let userProfile = state.userProfile
          else { return .none }
          
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .profile(userProfile.id)
            )
          )
          return .none
          
        case .lentilButtonTapped:
          guard let topPostID = state.posts.first?.id
          else { return .none }
          state.scrollPosition = .top(topPostID)
          return .none
          
        case .createPublicationTapped:
          self.navigationApi.append(
            DestinationPath(
              navigationId: self.uuid.callAsFunction().uuidString,
              destination: .createPublication(.creatingPost)
            )
          )
          return .none
          
        case .scrollAnimationFinished:
          return .run { send in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            await send(.scrollAnimationFinishedResult)
          }
          
        case .scrollAnimationFinishedResult:
          state.scrollPosition = nil
          return .none
          
        case .connectWallet(let walletConnectAction):
          switch walletConnectAction {
            case .defaultProfileResponse(let defaultProfile):
              state.showProfile = Profile.State(navigationId: self.uuid.callAsFunction().uuidString, profile: defaultProfile)
              
              profilesCache.updateOrAppend(defaultProfile)
              
              return Effect(value: .showProfile(.remoteProfilePicture(.fetchImage)))
              
            default:
              return .none
          }
          
        case .showProfile:
          return .none
          
        case .post(let id, let postAction):
          if case .didAppear = postAction {
            for (index, currentID) in state.posts.ids.enumerated() {
              if id == currentID, (Float(index) / Float(state.posts.count) > 0.75) {
                // Reached more than 3/4 - load more publications
                return Effect(value: .fetchPublications)
              }
            }
          }
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
