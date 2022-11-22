// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture


struct Timeline: ReducerProtocol {
  struct State: Equatable {
    var userProfile: UserProfile? = nil
    var posts: IdentifiedArrayOf<Post.State> = []
    var cursorPublications: String?
    var cursorExplore: String?
    
    var walletConnect: Wallet.State = .init()
    var profile: Profile.State? = nil
    var createPublication: CreatePublication.State = .init()
  }
  
  enum Action: Equatable {
    enum ResponseType: Equatable {
      case explore, personal
    }
    case timelineAppeared
    case refreshFeed
    case fetchDefaultProfile
    case defaultProfileResponse(TaskResult<Model.Profile>)
    case fetchPublications
    case publicationsResponse(QueryResult<[Model.Publication]>, ResponseType)
    case loadMore
    
    case walletConnect(Wallet.Action)
    case profile(Profile.Action)
    case createPublication(CreatePublication.Action)
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.walletConnect, action: /Action.walletConnect) {
      Wallet()
    }
    
    Scope(state: \.createPublication, action: /Action.createPublication) {
      CreatePublication()
    }
    
    Reduce { state, action in
      enum CancelFetchPublicationsID {}
      
      switch action {
        case .timelineAppeared:
          state.userProfile = profileStorageApi.load()
          if state.userProfile != nil {
            return .merge(
              Effect(value: .refreshFeed),
              Effect(value: .fetchDefaultProfile)
            )
          }
          else {
            return Effect(value: .refreshFeed)
          }
          
        case .refreshFeed:
          state.cursorPublications = nil
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
          state.profile = Profile.State(profile: defaultProfile)
          return Effect(value: .profile(.remoteProfilePicture(.fetchImage)))
          
        case .defaultProfileResponse(let .failure(error)):
          log("Failed to load default profile for authenticated user", level: .error, error: error)
          return .none
          
        case .fetchPublications:
          return .run { [cursorPublications = state.cursorPublications, cursorExplore = state.cursorExplore, id = state.userProfile?.id] send in
            do {
              if let id {
                // TODO: Handle feed endpoint here
              }
              await send(.publicationsResponse(try await lensApi.trendingPublications(40, cursorExplore, .topCommented, [.post], id), .explore))
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
          
        case .publicationsResponse(let response, let responseType):
          response.data
            .filter { $0.typename == .post }
            .map { Post.State(post: .init(publication: $0)) }
            .forEach { postState in
              if let index = state.posts.firstIndex(where: { $0.post.publication.createdAt < postState.post.publication.createdAt }) {
                state.posts.updateOrInsert(postState, at: index)
              }
              else {
                state.posts.updateOrAppend(postState)
              }
            }
          
          switch responseType {
            case .explore:
              state.cursorExplore = response.cursorToNext
            case .personal:
              state.cursorPublications = response.cursorToNext
          }
          return .none
          
        case .walletConnect(let walletConnectAction):
          switch walletConnectAction {
            case .defaultProfileResponse(let defaultProfile):
              state.profile = Profile.State(profile: defaultProfile)
              return Effect(value: .profile(.remoteProfilePicture(.fetchImage)))
              
            default:
              return .none
          }
          
        case .profile:
          return .none
          
        case .createPublication:
          return .none
          
        case .post:
          return .none
      }
    }
    .ifLet(\.profile, action: /Action.profile) {
      Profile()
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
