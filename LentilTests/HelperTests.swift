// LentilTests
// Created by Laura and Cordt Zermin

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
  
  func testHexIsCalculated() {
    let firstWOPrefix = "0"
    let first = "0x0"
    let secondWOPrefix = "f"
    let second = "0xf"
    let thirdWOPrefix = "ef"
    let third = "0xef"
    let fourthWOPrefix = "e5ff"
    let fourth = "0xe5ff"
    let fifthWOPrefix = ""
    let fifth = "xxxe5ff"
    XCTAssertEqual(hexToDecimal(firstWOPrefix), 0)
    XCTAssertEqual(hexToDecimal(first), 0)
    XCTAssertEqual(hexToDecimal(secondWOPrefix), 15)
    XCTAssertEqual(hexToDecimal(second), 15)
    XCTAssertEqual(hexToDecimal(thirdWOPrefix), 239)
    XCTAssertEqual(hexToDecimal(third), 239)
    XCTAssertEqual(hexToDecimal(fourthWOPrefix), 58879)
    XCTAssertEqual(hexToDecimal(fourth), 58879)
    XCTAssertEqual(hexToDecimal(fifthWOPrefix), nil)
    XCTAssertEqual(hexToDecimal(fifth), nil)
  }
  
  func testLensDMConversationIDsAreCalculated() {
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x2f").build()?.conversationID, "lens.dev/dm/0x2f-0x3fc0")
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x4fad").build()?.conversationID, "lens.dev/dm/0x3fc0-0x4fad")
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x62fa").build()?.conversationID, "lens.dev/dm/0x3fc0-0x62fa")
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x62fa").build()?.conversationID, "lens.dev/dm/0x3fc0-0x62fa")
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x605c").build()?.conversationID, "lens.dev/dm/0x3fc0-0x605c")
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x15").build()?.conversationID, "lens.dev/dm/0x15-0x3fc0")
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x06").build()?.conversationID, "lens.dev/dm/0x06-0x3fc0")
    XCTAssertEqual(XMTPClient.ConversationID.lens("0x3fc0", "0x638a").build()?.conversationID, "lens.dev/dm/0x3fc0-0x638a")
  }
}
