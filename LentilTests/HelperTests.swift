// LentilTests

import XCTest
@testable import Lentil


final class HelperTests: XCTestCase {
  
  override func setUpWithError() throws {}
  override func tearDownWithError() throws {}
  
  func testPublicationDateIsCalculated() {
    let oneSecondAgo = Date().addingTimeInterval(-1)
    let thirtySecondsAgo = Date().addingTimeInterval(-30)
    let oneMinuteAgo = Date().addingTimeInterval(-60 * 1)
    let fiveMinutesAgo = Date().addingTimeInterval(-60 * 5)
    let oneHourAgo = Date().addingTimeInterval(-60 * 60 * 1)
    let fiveHoursAgo = Date().addingTimeInterval(-60 * 60 * 5)
    let oneDayAgo = Date().addingTimeInterval(-60 * 60 * 24)
    let fiveDaysAgo = Date().addingTimeInterval(-60 * 60 * 24 * 5)
    
    XCTAssertEqual(age(oneSecondAgo), "1 second")
    XCTAssertEqual(age(thirtySecondsAgo), "30 seconds")
    XCTAssertEqual(age(oneMinuteAgo), "1 minute")
    XCTAssertEqual(age(fiveMinutesAgo), "5 minutes")
    XCTAssertEqual(age(oneHourAgo), "1 hour")
    XCTAssertEqual(age(fiveHoursAgo), "5 hours")
    XCTAssertEqual(age(oneDayAgo), "1 day")
    
    XCTAssertNotEqual(age(fiveDaysAgo), "5 days")
  }
}
