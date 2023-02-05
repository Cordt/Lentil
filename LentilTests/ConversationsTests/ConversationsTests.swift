// LentilTests

import ComposableArchitecture
import XCTest
@testable import Lentil

@MainActor
final class ConversationsTests: XCTestCase {
  
  func testBundleIsLoadedFromKeychain() {
    let store = TestStore(
      initialState: Conversations.State(),
      reducer: Conversations()
    )
    
    store.dependencies.xmtpConnector.tryLoadCLient = { true }
    
    store.send(.didAppear)
  }
}
