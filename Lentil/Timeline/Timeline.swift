// Lentil
// Created by Laura and Cordt Zermin

import Apollo
import ComposableArchitecture
import Foundation


struct Timeline: Reducer {
  struct State: Equatable {
    enum ScrollPosition: Equatable {
      case top(_ navigationID: String)
    }
    var userProfile: UserProfile? = nil
    var posts: IdentifiedArrayOf<Post.State> = []
    var scrollPosition: ScrollPosition?
    var isIndexing: Toast? = nil
    var loadingInFlight: Bool = false
    var unreadNotifications = 0
    
    var connectWallet: WalletConnection.State? = nil
    var showProfile: Profile.State? = nil
    
    var feedObserver: CollectionObserver<Model.Publication>? = nil
  }
  
  enum Action: Equatable {
    enum PublicationsResponse: Equatable {
      case upsert(_ publications: [Model.Publication])
      case delete(_ publicationIds: [Model.Publication.ID])
    }
    
    case timelineAppeared
    case refreshFeed
    case fetchDefaultProfile
    case defaultProfileResponse(TaskResult<Model.Profile>)
    case fetchPublications
    case publicationResponse(Model.Publication?)
    
    case observeTimelineUpdates
    case publicationsResponse(PublicationsResponse)
    
    case loadNotifications
    case notificationsResponse(TaskResult<PaginatedResult<[Model.Notification]>>)
    
    case updateIndexingToast(Toast?)
    
    case connectWalletTapped
    case setConnectWallet(WalletConnection.State?)
    case ownProfileTapped
    case lentilButtonTapped
    case showNotificationsTapped
    case createPublicationTapped
    case scrollAnimationFinished
    case scrollAnimationFinishedResult
    
    case connectWallet(WalletConnection.Action)
    case showProfile(Profile.Action)
    case post(id: Post.State.ID, action: Post.Action)
  }
  
  @Dependency(\.cacheOld) var cacheOld
  @Dependency(\.cache) var cache
  @Dependency(\.continuousClock) var clock
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.navigate) var navigate
  @Dependency(\.defaultsStorageApi) var defaultsStorageApi
  @Dependency(\.uuid) var uuid
  
  func fetchPublications(from publications: [Model.Publication], updating posts: IdentifiedArrayOf<Post.State>) -> IdentifiedArrayOf<Post.State> {
    var updatedPosts = posts
    
    // First, handle posts and mirrors
    let postsAndMirrors = publications
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
    let comments = publications
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
      .forEach { self.cacheOld.updateOrAppendPublication($0) }
    comments
      .forEach { self.cacheOld.updateOrAppendPublication($0) }
    parentPublications
      .forEach { self.cacheOld.updateOrAppendPublication($0) }
    
    // Write profiles to cache
    publications
      .forEach { self.cacheOld.updateOrAppendProfile($0.profile) }
    parentPublications
      .forEach { self.cacheOld.updateOrAppendProfile($0.profile) }
    
    updatedPosts.sort { $0.post.publication.createdAt > $1.post.publication.createdAt }
    return updatedPosts
  }
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .timelineAppeared:
          var effects: [Effect<Action>] = []
          state.userProfile = defaultsStorageApi.load(UserProfile.self) as? UserProfile
          if state.userProfile != nil && state.showProfile == nil { effects.append(.send(.fetchDefaultProfile)) }
          effects.append(.send(.observeTimelineUpdates))
          effects.append(.send(.refreshFeed))
          if state.userProfile != nil { effects.append(.send(.loadNotifications)) }
          return .merge(effects)
          
        case .refreshFeed:
          state.loadingInFlight = false
          return .send(.fetchPublications)
          
        case .fetchDefaultProfile:
          guard let userProfile = state.userProfile
          else { return .none }
          
          return .run { send in
            await send(.defaultProfileResponse(
              TaskResult {
                try await lensApi.defaultProfile(userProfile.address)
              }
            ))
          }
          
        case .defaultProfileResponse(let .success(defaultProfile)):
          state.showProfile = Profile.State(navigationId: self.uuid.callAsFunction().uuidString, profile: defaultProfile)
          self.cacheOld.updateOrAppendProfile(defaultProfile)
          return .none
          
        case .defaultProfileResponse(let .failure(error)):
          log("Failed to load default profile for authenticated user", level: .error, error: error)
          return .none
          
        case .fetchPublications:
          guard !state.loadingInFlight
          else { return .none }
          
          state.loadingInFlight = true
          if let id = state.userProfile?.id {
            return .run { _ in try await self.cache.loadAdditionalPublicationsForFeedAuthenticated(id) }
          }
          else {
            return .run { _ in try await self.cache.loadAdditionalPublicationsForFeed() }
          }
          
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
              else if let parentId = parent?.id, let post = self.cacheOld.publication(parentId) {
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
          self.cacheOld.updateOrAppendPublication(publication)
          return .none
          
        case .observeTimelineUpdates:
          state.feedObserver = self.cache.feedObserver()
          return .run { [events = state.feedObserver?.events] send in
            guard let events else { return }
            for try await event in events {
              switch event {
                case .initial(let publications), .update(let publications):
                  await send(.publicationsResponse(.upsert(publications)))
                  
                case .delete(let deletionKeys):
                  await send(.publicationsResponse(.delete(deletionKeys)))
              }
            }
          }
          
        case .publicationsResponse(let result):
          switch result {
            case .upsert(let publications):
              let updatedPosts = self.fetchPublications(from: publications, updating: state.posts)
              if updatedPosts != state.posts { state.posts = updatedPosts }
              
            case .delete(let publicationIds):
              publicationIds.forEach { id in
                if state.posts[id: id] != nil {
                  state.posts.remove(id: id)
                }
                else {
                  state.posts.forEach {
                    if $0.comments[id: id] != nil {
                      state.posts[id: $0.id]?.comments.remove(id: id)
                      return
                    }
                  }
                }
              }
              
          }
          state.loadingInFlight = false
          return .none
          
        case .loadNotifications:
          guard let userProfile = self.defaultsStorageApi.load(UserProfile.self) as? UserProfile
          else { return .none }
          
          return .run { send in
            await send(.notificationsResponse(
              TaskResult { try await self.lensApi.notifications(userProfile.id, 10, nil) }
            ))
          }
          
        case .notificationsResponse(.success(let result)):
          let sortedNotificaitons = result.data.sorted { $0.createdAt > $1.createdAt }
          var unreadNotifications = 0
          if let latestReadNotification = self.defaultsStorageApi.load(NotificationsLatestRead.self) as? NotificationsLatestRead {
            for notification in sortedNotificaitons {
              if latestReadNotification.createdAt < notification.createdAt { unreadNotifications += 1 }
              else { break }
            }
          }
          state.unreadNotifications = unreadNotifications
          return .none
          
        case .notificationsResponse(.failure(let error)):
          log("Failed to load notifications", level: .error, error: error)
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
          
          self.navigate.navigate(.profile(userProfile.id))
          return .none
          
        case .lentilButtonTapped:
          guard let topPostID = state.posts.first?.id
          else { return .none }
          state.scrollPosition = .top(topPostID)
          return .none
          
        case .showNotificationsTapped:
          self.navigate.navigate(.showNotifications)
          return .none
          
        case .createPublicationTapped:
          self.navigate.navigate(.createPublication(.creatingPost))
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
              state.userProfile = defaultsStorageApi.load(UserProfile.self) as? UserProfile
              state.showProfile = Profile.State(navigationId: self.uuid.callAsFunction().uuidString, profile: defaultProfile)
              self.cacheOld.updateOrAppendProfile(defaultProfile)
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
      WalletConnection()
    }
    .ifLet(\.showProfile, action: /Action.showProfile) {
      Profile()
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
  }
}
