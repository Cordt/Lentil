// LentilTests
// Created by Laura and Cordt Zermin

import XCTest
import ComposableArchitecture
@testable import Lentil


@MainActor
final class RootTests: XCTestCase {
  override func setUpWithError() throws {}
  override func tearDownWithError() throws {}
  
  func testValidatesTokenAndOpensApp() async throws {
    let clock = TestClock()
    let store = TestStore(
      initialState: Root.State(timelineState: .init()),
      reducer: Root()
    ) {
      $0.defaultsStorageApi.load = { _ in UserProfile(id: "abc", handle: "@Cordt", address: "0x123") }
      $0.keychainApi.checkFor = { _ in true }
      $0.keychainApi.get = { _ in "token" }
      $0.lensApi.verify = {
        try await clock.sleep(for: .seconds(1))
        return true
      }
      
      $0.withRandomNumberGenerator = WithRandomNumberGenerator(PredictableNumberGenerator())
      $0.continuousClock = clock
    }
    
    await store.send(.loadingScreenAppeared)
    await store.receive(.startTimer)
    await store.receive(.checkAuthenticationStatus)
    await clock.advance(by: .seconds(1))
    await store.receive(.refreshTokenResponse(true))
    await clock.advance(by: .seconds(0.5))
    await store.receive(.switchProgressLabel) {
      $0.loadingText = Root.loadingTexts[1]
      $0.currentText = 1
    }
    await clock.advance(by: .seconds(1.0))
    await store.receive(.hideLoadingScreen) {
      $0.isLoading = false
    }
    await store.send(.loadingScreenDisappeared)
  }
  
  func testInvalidTokenRefreshesToken() async throws {
    let store = TestStore(
      initialState: Root.State(timelineState: .init()),
      reducer: Root()
    )
    let clock = TestClock()
    
    store.dependencies.keychainApi.checkFor = { _ in true }
    store.dependencies.keychainApi.get = { _ in "token" }
    store.dependencies.defaultsStorageApi.load = { _ in UserProfile(id: "abc", handle: "@Cordt", address: "0x123") }
    store.dependencies.lensApi.verify = {
      try await clock.sleep(for: .seconds(1))
      return false
    }
    store.dependencies.lensApi.refreshAuthentication = { /* Success */ }
    store.dependencies.withRandomNumberGenerator = WithRandomNumberGenerator(PredictableNumberGenerator())
    store.dependencies.continuousClock = clock
    
    await store.send(.loadingScreenAppeared)
    await store.receive(.startTimer)
    await store.receive(.checkAuthenticationStatus)
    await clock.advance(by: .seconds(1))
    await store.receive(.refreshTokenResponse(false))
    await clock.advance(by: .seconds(0.5))
    await store.receive(.switchProgressLabel) {
      $0.loadingText = Root.loadingTexts[1]
      $0.currentText = 1
    }
    await clock.advance(by: .seconds(1.0))
    await store.receive(.hideLoadingScreen) {
      $0.isLoading = false
    }
    await store.send(.loadingScreenDisappeared)
  }
  
  func testInvalidTokenDeletesTokensAndUser() async throws {
    let store = TestStore(
      initialState: Root.State(timelineState: .init()),
      reducer: Root()
    )
    let clock = TestClock()
    var tokensDeleted = false
    var userDeleted = false
    var cacheCleared = false
    
    store.dependencies.withRandomNumberGenerator = WithRandomNumberGenerator(PredictableNumberGenerator())
    store.dependencies.continuousClock = clock
    
    store.dependencies.keychainApi.checkFor = { _ in true }
    store.dependencies.keychainApi.get = { _ in "token" }
    store.dependencies.keychainApi.delete = { _ in tokensDeleted = true }
    store.dependencies.cache.clearCache = { cacheCleared = true }
    store.dependencies.lensApi.verify = {
      try await clock.sleep(for: .seconds(1))
      return false
    }
    store.dependencies.lensApi.refreshAuthentication = { /* Failure */ throw ApiError.unauthenticated }
    store.dependencies.defaultsStorageApi.load = { _ in UserProfile(id: "abc", handle: "@Cordt", address: "0x123") }
    store.dependencies.defaultsStorageApi.remove = { _ in userDeleted = true }
    
    await store.send(.loadingScreenAppeared)
    await store.receive(.startTimer)
    await store.receive(.checkAuthenticationStatus)
    await clock.advance(by: .seconds(1))
    await store.receive(.refreshTokenResponse(false))
    await clock.advance(by: .seconds(0.5))
    await store.receive(.switchProgressLabel) {
      $0.loadingText = Root.loadingTexts[1]
      $0.currentText = 1
    }
    await clock.advance(by: .seconds(1.0))
    await store.receive(.hideLoadingScreen) {
      $0.isLoading = false
    }
    await store.send(.loadingScreenDisappeared)
    
    XCTAssertTrue(tokensDeleted && userDeleted && cacheCleared)
  }
  
  func testRootScreenDoesItsThing() async throws {
    let store = TestStore(
      initialState: Root.State.init(timelineState: .init()),
      reducer: Root()
    )
    
    store.dependencies.navigationApi.eventStream = { NavigationEvents() }
    
    await store.send(.rootAppeared)
    await store.send(.rootDisappeared)
  }
  
  func testToastIsShownWhileIndexing() async throws {
    let store = TestStore(
      initialState: Root.State(timelineState: .init(), createPublication: CreatePublication.State(reason: .creatingPost)),
      reducer: Root()
    )
    let publication = MockData.mockPublications[0]
    
    store.dependencies.uuid = .incrementing
    
    store.dependencies.cache.updateOrAppendPublication = { _ in }
    store.dependencies.lensApi.publication = { _ in publication }
    store.dependencies.navigationApi.remove = { _ in }
    
    await store.send(.createPublication(.dismissView("abc-def"))) {
      $0.timelineState.isIndexing = Toast(message: "Indexing publication", duration: .long)
    }
    await store.receive(.timelineAction(.publicationResponse(publication))) {
      $0.timelineState.posts.append(
        .init(
          post: .init(publication: publication),
          typename: .post
        )
      )
      $0.timelineState.isIndexing = nil
    }
  }
  
  func testToastIsHiddenWhenIndexingFails() async throws {
    let store = TestStore(
      initialState: Root.State(timelineState: .init(), createPublication: CreatePublication.State(reason: .creatingPost)),
      reducer: Root()
    )
    let clock = TestClock()
    
    store.dependencies.continuousClock = clock
    store.dependencies.uuid = .incrementing
    
    store.dependencies.cache.updateOrAppendPublication = { _ in }
    store.dependencies.lensApi.publication = { _ in nil }
    store.dependencies.navigationApi.remove = { _ in }
    
    await store.send(.createPublication(.dismissView("abc-def"))) {
      $0.timelineState.isIndexing = Toast(message: "Indexing publication", duration: .long)
    }
    
    // Waiting 5 * 2 seconds, retrying
    await clock.advance(by: .seconds(25))
    
    await store.receive(.timelineAction(.publicationResponse(nil))) {
      $0.timelineState.isIndexing = nil
    }
  }
}
