// LentilTests
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class ProfileTests: XCTestCase {
  
  override func setUpWithError() throws {}
  override func tearDownWithError() throws {}
  
  func testUsersPublicationsAreLoaded() async throws {
    let store = TestStore(initialState: Profile.State(profile: MockData.mockProfiles[0]), reducer: Profile())
    let publications = [MockData.mockPublications[0]]
    
    store.dependencies.uuid = .incrementing
    
    store.dependencies.cache.updateOrAppendPublication = { _ in }
    store.dependencies.cache.updateOrAppendProfile = { _ in }
    store.dependencies.lensApi.publications = { _, _, _, _, _ in PaginatedResult(data: publications, cursor: .init()) }
    
    await store.send(.didAppear)
    await store.receive(.fetchPublications)
    await store.receive(.publicationsResponse(.success(publications))) {
      $0.posts = [
        Post.State(
          post: .init(publication: publications[0]),
          typename: .post
        )
      ]
    }
  }
}
