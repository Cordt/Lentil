// LentilTests
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class TimelineTests: XCTestCase {
  
  override func setUpWithError() throws {}
  override func tearDownWithError() throws {}
  
  func testExplorePublicationsAreLoaded() async throws {
    let store = TestStore(initialState: Timeline.State(), reducer: Timeline())
    let explorePublications = [MockData.mockPublications[0]]
    
    store.dependencies.uuid = .incrementing
    
    store.dependencies.cache.updateOrAppendPublication = { _ in }
    store.dependencies.cache.updateOrAppendProfile = { _ in }
    store.dependencies.lensApi.explorePublications = { _, _, _, _, _ in PaginatedResult(data: explorePublications, cursor: .init(next: "cursor")) }
    store.dependencies.profileStorageApi.load = { nil }
    
    await store.send(.timelineAppeared)
    await store.receive(.refreshFeed)
    await store.receive(.fetchPublications) {
      $0.loadingInFlight = true
    }
    await store.receive(.publicationsResponse(.init(publications: explorePublications, cursorExplore: .init(next: "cursor"), cursorFeed: .init()))) {
      $0.posts.append(Post.State(
        navigationId: "00000000-0000-0000-0000-000000000000",
        post: .init(publication: explorePublications.first!),
        typename: .post
      ))
      $0.cursorExplore = .init(next: "cursor")
      $0.loadingInFlight = false
    }
  }
  
  func testDefaultProfileIsFetchedThenFeedIsLoaded() async throws {
    let store = TestStore(initialState: Timeline.State(), reducer: Timeline())
    let clock = TestClock()
    let explorePublications = MockData.mockPublications[0]
    let feedPublications = MockData.mockPublications[1]
    
    store.dependencies.continuousClock = clock
    store.dependencies.uuid = .incrementing
    
    store.dependencies.cache.updateOrAppendPublication = { _ in }
    store.dependencies.cache.updateOrAppendProfile = { _ in }
    store.dependencies.lensApi.defaultProfile = { _ in
      try await clock.sleep(for: .seconds(1))
      return MockData.mockProfiles[0]
    }
    store.dependencies.lensApi.explorePublications = { _, _, _, _, _ in
      try await clock.sleep(for: .seconds(1))
      return PaginatedResult(data: [explorePublications], cursor: .init(next: "cursor explore"))
    }
    store.dependencies.lensApi.feed = { _, _, _, _ in
      try await clock.sleep(for: .seconds(1))
      return PaginatedResult(data: [feedPublications], cursor: .init(next: "cursor feed"))
    }
    store.dependencies.profileStorageApi.load = { MockData.mockUserProfile }
    
    await store.send(.timelineAppeared) {
      $0.userProfile = MockData.mockUserProfile
    }
    await store.receive(.fetchDefaultProfile)
    await store.receive(.refreshFeed)
    await store.receive(.fetchPublications) {
      $0.loadingInFlight = true
    }
    await clock.advance(by: .seconds(1))
    await store.receive(.defaultProfileResponse(.success(MockData.mockProfiles[0]))) {
      $0.showProfile = Profile.State(
        navigationId: "00000000-0000-0000-0000-000000000000",
        profile: MockData.mockProfiles[0]
      )
    }
    await clock.advance(by: .seconds(2))
    await store.receive(
      .publicationsResponse(
        .init(
          publications: [feedPublications, explorePublications],
          cursorExplore: .init(next: "cursor explore"),
          cursorFeed: .init(next: "cursor feed")
        )
      )
    ) {
      $0.posts.append(Post.State(
        navigationId: "00000000-0000-0000-0000-000000000001",
        post: .init(publication: feedPublications),
        typename: .post
      ))
      $0.posts.append(Post.State(
        navigationId: "00000000-0000-0000-0000-000000000002",
        post: .init(publication: explorePublications),
        typename: .post
      ))
      $0.cursorExplore = .init(next: "cursor explore")
      $0.cursorFeed = .init(next: "cursor feed")
      $0.loadingInFlight = false
    }
  }
  
  func testWalletConnectIsOpened() async throws {
    let store = TestStore(initialState: Timeline.State(), reducer: Timeline())
    
    await store.send(.connectWalletTapped) {
      $0.connectWallet = .init()
    }
  }
  
  func testProfileIsLoadedAfterWalletConnected() async throws {
    let store = TestStore(initialState: Timeline.State(connectWallet: .init()), reducer: Timeline())
    
    store.dependencies.uuid = .incrementing
    
    store.dependencies.cache.updateOrAppendProfile = { _ in }
    store.dependencies.profileStorageApi.load = { MockData.mockUserProfile }
    
    await store.send(.connectWallet(.defaultProfileResponse(MockData.mockProfiles[0]))) {
      $0.userProfile = MockData.mockUserProfile
      $0.showProfile = Profile.State(navigationId: "00000000-0000-0000-0000-000000000000", profile: MockData.mockProfiles[0])
    }
  }
  
  func testAssociatedPostIsAddedToIndexedComment() async throws {
    let store = TestStore(initialState: Timeline.State(), reducer: Timeline())
    let comment = MockData.mockComments[0]
    let parent = MockData.mockPosts[0]
    
    store.dependencies.uuid = .incrementing
    
    store.dependencies.cache.publication = { _ in parent }
    store.dependencies.cache.updateOrAppendPublication = { _ in }
    
    await store.send(.publicationResponse(comment)) {
      let postState = Post.State(
        navigationId: "00000000-0000-0000-0000-000000000001",
        post: .init(publication: parent),
        typename: .post,
        comments: [
          Post.State(
            navigationId: "00000000-0000-0000-0000-000000000000",
            post: .init(publication: comment),
            typename: .comment
          )
        ]
      )
      
      $0.posts.append(postState)
      $0.isIndexing = nil
    }
  }
}
