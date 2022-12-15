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
    
    let store = TestStore(
      initialState: Root.State(
        isLoading: true,
        timelineState: .init()
      ),
      reducer: Root()
    )
    
    let clock = TestClock()
    
    store.dependencies.authTokenApi = AuthTokenApi(
      store: { _, _ in () },
      load: { _ in "abc-def" },
      checkFor: { _ in true },
      delete: { () }
    )
    
    store.dependencies.profileStorageApi = ProfileStorageApi(
      store: { _ in },
      load: { UserProfile(id: "abc", handle: "@Cordt", address: "0x123") },
      remove: {}
    )
    
    store.dependencies.lensApi.verify = {
      try await clock.sleep(for: .seconds(1))
      return QueryResult(data: true)
    }
    
    store.dependencies.withRandomNumberGenerator = WithRandomNumberGenerator(PredictableNumberGenerator())
    store.dependencies.continuousClock = clock
    
    await store.send(.loadingScreenAppeared)
    await store.receive(.startTimer)
    await store.receive(.checkAuthenticationStatus)
    await clock.advance(by: .seconds(1))
    await store.receive(.refreshTokenResponse(QueryResult(data: true)))
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
}
