// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import SwiftUI

struct Root: ReducerProtocol {
  static let loadingTexts = [
    "plowing beds",
    "planting seeds",
    "tending to seedlings",
    "spreading some fertiliser",
    "letting the sun in",
    "hunting bugs",
    "loving thy garden 🌱"
  ]
  
  struct State: Equatable {
    var isLoading: Bool = true
    var loadingText = loadingTexts[0]
    var currentText: Int = 0
    
    var timelineState: Timeline.State
    
    var posts: IdentifiedArrayOf<Post.State> = []
    var comments: IdentifiedArrayOf<Post.State> = []
    var profiles: IdentifiedArrayOf<Profile.State> = []
    var createPublication: CreatePublication.State?
    var imageDetail: Image?
  }
  
  enum Action: Equatable {
    case loadingScreenAppeared
    case hideLoadingScreen
    case loadingScreenDisappeared
    case startTimer
    case switchProgressLabel
    
    case checkAuthenticationStatus
    case refreshTokenResponse(QueryResult<Bool>)
    
    case rootScreenAppeared
    case rootScreenDisappeared
    
    case timelineAction(Timeline.Action)
    
    case addPath(DestinationPath)
    case removePath(DestinationPath)
    case post(id: Post.State.ID, action: Post.Action)
    case comment(id: Post.State.ID, action: Post.Action)
    case profile(id: Profile.State.ID, action: Profile.Action)
    case createPublication(CreatePublication.Action)
  }
  
  @Dependency(\.authTokenApi) var authTokenApi
  @Dependency(\.cache) var cache
  @Dependency(\.continuousClock) var clock
  @Dependency(\.lensApi) var lensApi
  @Dependency(\.profileStorageApi) var profileStorageApi
  @Dependency(\.navigationApi) var navigationApi
  @Dependency(\.withRandomNumberGenerator) var randomNumberGenerator
  private enum TimerID {}
  private enum NavigationEventsID {}

  func fetchIndexedTransaction(txHash: String?, state: inout State) -> EffectTask<Action> {
    if let txHash {
      state.timelineState.isIndexing = Toast(message: "Indexing publication", duration: .long)
      return .task {
        do {
          var attempts = 5
          while attempts > 0 {
            if let publication = try await self.lensApi.publication(txHash).data {
              return .timelineAction(.publicationResponse(publication))
            }
            try await self.clock.sleep(for: .seconds(5))
            attempts -= 1
          }
          log("Failed to load recently created publication for TX Hash after 5 retries \(txHash)", level: .warn)
          return .timelineAction(.publicationResponse(nil))
          
        } catch let error {
          log("Failed to load recently created publication for TX Hash \(txHash)", level: .error, error: error)
          return .timelineAction(.publicationResponse(nil))
        }
      }
    }
    else {
      return .none
    }
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .loadingScreenAppeared:
          state.currentText = Int(self.randomNumberGenerator.callAsFunction {
            $0.next(upperBound: UInt8(state.loadingText.count) - 1)
          })
          return .merge(
            Effect(value: .startTimer),
            Effect(value: .checkAuthenticationStatus)
          )
          
        case .hideLoadingScreen:
          state.isLoading = false
          return .none
          
        case .loadingScreenDisappeared:
          return .cancel(id: TimerID.self)
          
        case .startTimer:
          return .run { [isLoading = state.isLoading] send in
            guard isLoading else { return }
            for await _ in self.clock.timer(interval: .seconds(1.5)) {
              await send(.switchProgressLabel, animation: .default)
            }
          }
          .cancellable(id: TimerID.self, cancelInFlight: true)
          
        case .switchProgressLabel:
          let itemNumber = (state.currentText + 1) % Root.loadingTexts.count
          state.currentText += 1
          state.loadingText = Root.loadingTexts[itemNumber]
          return .none
          
        case .checkAuthenticationStatus:
          do {
            // Verify that both access token and user are available
            if try self.authTokenApi.checkFor(.access),
               try self.authTokenApi.checkFor(.refresh),
               self.profileStorageApi.load() != nil {
              
              // Verify that the access token is still valid
              return .run { send in
                let valid = try await self.lensApi.verify()
                await send(.refreshTokenResponse(valid))
              }
            }
            else {
              try self.authTokenApi.delete()
              self.profileStorageApi.remove()
              self.cache.clearCache()
              
              // No valid tokens or profile available, open app
              return .run { send in
                try await self.clock.sleep(for: .seconds(1))
                await send(.hideLoadingScreen)
              }
            }
          } catch let error {
            log("Failed to load access tokens or user profile", level: .error, error: error)
            return .run { send in
              try await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
            }
          }
          
        case .refreshTokenResponse(let tokenIsValid):
          if tokenIsValid.data {
            // Valid tokens and profile available, open app
            return .run { send in
              try await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
            }
          }
          else {
            return .run { send in
              try await self.lensApi.refreshAuthentication()
              try await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
              
            } catch: { error, send in
              try? self.authTokenApi.delete()
              self.profileStorageApi.remove()
              self.cache.clearCache()
              log("Failed to refresh token, logging user out", level: .debug, error: error)
              try? await self.clock.sleep(for: .seconds(1))
              await send(.hideLoadingScreen)
            }
          }
          
        case .rootScreenAppeared:
          return .run { send in
            do {
              for try await event in self.navigationApi.eventStream {
                switch event {
                  case .append(let destinationPath):
                    await send(.addPath(destinationPath))
                  case .remove(let destinationPath):
                    await send(.removePath(destinationPath))
                }
              }
            } catch let error {
              log("Failed to receive navigation events", level: .error, error: error)
            }
          }
          .cancellable(id: NavigationEventsID.self, cancelInFlight: true)
          
        case .rootScreenDisappeared:
          return .cancel(id: NavigationEventsID.self)
          
        case .timelineAction(let timelineAction):
          if case .post(_, let postAction) = timelineAction {
            if case .post(.mirrorSuccess(let txHash)) = postAction {
              return fetchIndexedTransaction(txHash: txHash, state: &state)
            }
            else {
              return .none
            }
          }
          else {
            return .none
          }
          
        case .addPath(let destinationPath):
          switch destinationPath.destination {
            case .publication(let elementId):
              guard let publication = self.cache.publication(elementId)
              else { return .none }
              
              switch publication.typename {
                case .post:
                  let postState = Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication), typename: .post)
                  state.posts.updateOrAppend(postState)
                case .comment:
                  let commentState = Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication), typename: .comment)
                  state.comments.updateOrAppend(commentState)
                case .mirror:
                  let mirrorState = Post.State(navigationId: destinationPath.navigationId, post: .init(publication: publication), typename: .mirror)
                  state.posts.updateOrAppend(mirrorState)
                  return .none
              }
              
            case .profile(let elementId):
              guard let profile = self.cache.profile(elementId)
              else { return .none }
              
              let profileState = Profile.State(navigationId: destinationPath.navigationId, profile: profile)
              state.profiles.updateOrAppend(profileState)
              
            case .createPublication(let reason):
              state.createPublication = CreatePublication.State(navigationId: destinationPath.navigationId, reason: reason)
              
            case .imageDetail(let url):
              guard let medium = self.cache.medium(url.absoluteString),
                    case .image = medium.mediaType,
                    let imageData = self.cache.mediumData(url.absoluteString)?.data,
                    let uiImage = imageData.image(for: .feed, and: .display)
              else { return .none }
              
              state.imageDetail = Image(uiImage: uiImage)
          }
          return .none
          
        case .removePath(let destinationPath):
          switch destinationPath.destination {
            case .publication:
              state.posts.remove(id: destinationPath.navigationId)
              state.comments.remove(id: destinationPath.navigationId)
              
            case .profile:
              state.profiles.remove(id: destinationPath.navigationId)
              
            case .createPublication:
              state.createPublication = nil
              
            case .imageDetail:
              state.imageDetail = nil
          }
          return .none
          
        case .post, .comment, .profile:
          return .none
          
        case .createPublication(let createPublicationAction):
          if case .dismissView(let txHash) = createPublicationAction {
            return fetchIndexedTransaction(txHash: txHash, state: &state)
          }
          else {
            return .none
          }
      }
    }
    .forEach(\.posts, action: /Action.post) {
      Post()
    }
    .forEach(\.comments, action: /Action.comment) {
      Post()
    }
    .forEach(\.profiles, action: /Action.profile) {
      Profile()
    }
    .ifLet(\.createPublication, action: /Action.createPublication) {
      CreatePublication()
    }
    
    Scope(
      state: \State.timelineState,
      action: /Action.timelineAction
    ) {
      Timeline()
    }
  }
}
