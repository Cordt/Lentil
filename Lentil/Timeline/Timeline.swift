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
    struct PublicationsResponse: Equatable {
      let publications: [Model.Publication]
      let cursorExplore: String?
      let cursorFeed: String?
    }
    
    case timelineAppeared
    case refreshFeed
    case fetchDefaultProfile
    case defaultProfileResponse(TaskResult<Model.Profile>)
    case fetchPublications
    case publicationResponse(Model.Publication?)
    case publicationsResponse(PublicationsResponse)
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
  
  func fetchPublications(from response: Action.PublicationsResponse, updating posts: IdentifiedArrayOf<Post.State>) -> IdentifiedArrayOf<Post.State> {
    var updatedPosts = posts
    
    // First, handle posts and mirrors
    let postsAndMirrors = response.publications
      .filter {
        if case .post = $0.typename { return true }
        if case .mirror = $0.typename { return true }
        return false
      }
    
    postsAndMirrors
      .map { publication in
        if var postState = posts.first(where: { $0.post.publication.id == publication.id }) {
          postState.post.publication = publication
          return postState
        }
        else {
          return Post.State(
            navigationId: uuid.callAsFunction().uuidString,
            post: .init(publication: publication),
            typename: Post.State.Typename.from(typename: publication.typename)
          )
        }
      }
      .forEach { updatedPosts.updateOrAppend($0) }
    
    // Second, handle comments
    let comments = response.publications
      .filter {
        if case .comment = $0.typename { return true }
        else { return false }
      }
    
    var parentPublications: [Model.Publication] = []
    comments
      .map { publication in
        if var postState = posts.first(where: { $0.post.publication.id == publication.id }) {
          postState.post.publication = publication
          return postState
        }
        else {
          return Post.State(
            navigationId: uuid.callAsFunction().uuidString,
            post: .init(publication: publication),
            typename: Post.State.Typename.from(typename: publication.typename)
          )
        }
      }
      .forEach { commentState in
        if case .comment(let parent) = commentState.post.publication.typename {
          guard let parent else { return }
          parentPublications.append(parent)
          if let postState = updatedPosts.first(where: { $0.post.publication.id == parent.id }) {
            updatedPosts[id: postState.id]?.comments = [commentState]
          }
          else {
            updatedPosts.append(
              Post.State(
                navigationId: uuid.callAsFunction().uuidString,
                post: Publication.State(publication: parent),
                typename: Post.State.Typename.from(typename: parent.typename),
                comments: [commentState]
              )
            )
          }
        }
      }
    
    // Write publications to cache
    postsAndMirrors
      .forEach { publicationsCache.updateOrAppend($0) }
    comments
      .forEach { publicationsCache.updateOrAppend($0) }
    parentPublications
      .forEach { publicationsCache.updateOrAppend($0) }
    
    // Write profiles to cache
    response.publications
      .forEach { profilesCache.updateOrAppend($0.profile) }
    parentPublications
      .forEach { profilesCache.updateOrAppend($0.profile) }
    
    updatedPosts.sort { $0.post.publication.createdAt > $1.post.publication.createdAt }
    return updatedPosts
  }
  
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
            if let id {
              let feed = try await lensApi.feed(40, cursorFeed, id, .fetchIgnoringCacheData, id)
              let exploration = try await lensApi.explorePublications(10, cursorExplore, .latest, [.post, .comment, .mirror], .fetchIgnoringCacheData, id)
              await send(
                .publicationsResponse(
                  Action.PublicationsResponse(
                    publications: feed.data + exploration.data,
                    cursorExplore: exploration.cursorToNext,
                    cursorFeed: feed.cursorToNext
                  )
                )
              )
            }
            else {
              let exploration = try await lensApi.explorePublications(50, cursorExplore, .latest, [.post, .comment, .mirror], .fetchIgnoringCacheData, id)
              await send(
                .publicationsResponse(
                  Action.PublicationsResponse(
                    publications: exploration.data,
                    cursorExplore: exploration.cursorToNext,
                    cursorFeed: nil
                  )
                )
              )
            }
          } catch: { error, send in
            log("Failed to load timeline", level: .error, error: error)
            await send(.fetchingFailed)
          }
          .cancellable(id: CancelFetchPublicationsID.self)
          
        case .publicationResponse(let publication):
          state.indexingPost = false
          guard let publication else { return .none }
          
          if var postState = state.posts.first(where: { $0.post.publication.id == publication.id }) {
            postState.post.publication = publication
          }
          else {
            let postState = Post.State(
              navigationId: uuid.callAsFunction().uuidString,
              post: .init(publication: publication),
              typename: Post.State.Typename.from(typename: publication.typename)
            )
            state.posts.insert(postState, at: 0)
          }
          publicationsCache.append(publication)
          return .none
          
        case .publicationsResponse(let response):
          let updatedPosts = self.fetchPublications(from: response, updating: state.posts)
          if updatedPosts != state.posts { state.posts = updatedPosts }
          state.cursorExplore = response.cursorExplore
          state.cursorFeed = response.cursorFeed
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
              state.userProfile = profileStorageApi.load()
              state.showProfile = Profile.State(navigationId: self.uuid.callAsFunction().uuidString, profile: defaultProfile)
              profilesCache.updateOrAppend(defaultProfile)
              
              return Effect(value: .showProfile(.remoteProfilePicture(.fetchImage)))
              
            default:
              return .none
          }
          
        case .showProfile, .post:
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
