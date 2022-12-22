// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import Foundation


struct Timeline: ReducerProtocol {
  struct State: Equatable {
    enum ScrollPosition: Equatable {
      case top(_ navigationID: String)
    }
    var userProfile: UserProfile? = nil
    var posts: IdentifiedArrayOf<Post.State> = []
    var scrollPosition: ScrollPosition?
    var cursorFeed: String?
    var cursorExplore: String?
    var isIndexing: Toast? = nil
    var loadingInFlight: Bool = false
    
    var connectWallet: Wallet.State? = nil
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
    
    case updateIndexingToast(Toast?)
    
    case connectWalletTapped
    case setConnectWallet(Wallet.State?)
    case ownProfileTapped
    case lentilButtonTapped
    case createPublicationTapped
    case scrollAnimationFinished
    case scrollAnimationFinishedResult
    
    case connectWallet(Wallet.Action)
    case showProfile(Profile.Action)
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.cache) var cache
  @Dependency(\.continuousClock) var clock
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
      .forEach { self.cache.updateOrAppendPublication($0) }
    comments
      .forEach { self.cache.updateOrAppendPublication($0) }
    parentPublications
      .forEach { self.cache.updateOrAppendPublication($0) }
    
    // Write profiles to cache
    response.publications
      .forEach { self.cache.updateOrAppendProfile($0.profile) }
    parentPublications
      .forEach { self.cache.updateOrAppendProfile($0.profile) }
    
    updatedPosts.sort { $0.post.publication.createdAt > $1.post.publication.createdAt }
    return updatedPosts
  }
  
  var body: some ReducerProtocol<State, Action> {
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
          self.cache.updateOrAppendProfile(defaultProfile)
          return .none
          
        case .defaultProfileResponse(let .failure(error)):
          log("Failed to load default profile for authenticated user", level: .error, error: error)
          return .none
          
        case .fetchPublications:
          guard !state.loadingInFlight
          else { return .none }
          
          state.loadingInFlight = true
          return .run { [cursorFeed = state.cursorFeed, cursorExplore = state.cursorExplore, id = state.userProfile?.id] send in
            if let id {
              let feed = try await lensApi.feed(40, cursorFeed, id, id)
              let exploration = try await lensApi.explorePublications(10, cursorExplore, .latest, [.post, .comment, .mirror], id)
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
              let exploration = try await lensApi.explorePublications(50, cursorExplore, .latest, [.post, .comment, .mirror], nil)
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
          state.isIndexing = nil
          guard let publication else { return .none }
          
          if var postState = state.posts.first(where: { $0.post.publication.id == publication.id }) {
            postState.post.publication = publication
          }
          else {
            let publicationState = Post.State(
              navigationId: uuid.callAsFunction().uuidString,
              post: .init(publication: publication),
              typename: Post.State.Typename.from(typename: publication.typename)
            )
            
            if case .comment(let parent) = publication.typename {
              if var postState = state.posts.first(where: { $0.post.publication.id == parent?.id }) {
                postState.comments.updateOrAppend(publicationState)
                state.posts[id: postState.id] = postState
              }
              else if let parentId = parent?.id, let post = self.cache.publication(parentId) {
                let parentState = Post.State(
                  navigationId: uuid.callAsFunction().uuidString,
                  post: .init(publication: post),
                  typename: Post.State.Typename.from(typename: post.typename),
                  comments: [publicationState]
                )
                state.posts.insert(parentState, at: 0)
              }
              else {
                log("Couldn't find parent publication for published comment", level: .warn)
              }
            }
            else {            
              state.posts.insert(publicationState, at: 0)
            }
          }
          self.cache.updateOrAppendPublication(publication)
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
          
        case .updateIndexingToast(let toast):
          state.isIndexing = toast
          return .none
          
        case .connectWalletTapped:
          state.connectWallet = .init()
          return .none
          
        case .setConnectWallet(let walletState):
          state.connectWallet = walletState
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
            try await self.clock.sleep(for: .seconds(1))
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
              self.cache.updateOrAppendProfile(defaultProfile)
              return .none
              
            default:
              return .none
          }
          
        case .showProfile:
          return .none
          
        case .post(let id, let postAction):
          return .run(priority: .background) { [posts = state.posts] in
            if case .didAppear = postAction {
              for (index, currentID) in posts.ids.enumerated() {
                if id == currentID, (Float(index) / Float(posts.count) > 0.75) {
                  // Reached more than 3/4 - load more publications
                  await $0(.fetchPublications)
                }
              }
            }
          }
      }
    }
    .ifLet(\.connectWallet, action: /Action.connectWallet) {
      Wallet()
    }
    .ifLet(\.showProfile, action: /Action.showProfile) {
      Profile()
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
