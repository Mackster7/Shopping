//
//  ShoppingUITests.swift
//  ShoppingUITests
//
//  Created by Berkay Sancar on 26.07.2024.
//

import XCTest

final class ShoppingUITests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testWithAI() async {
    let app = await XCUIApplication()
    await app.launch()

    let testSteps = [
      "Verify user is in app home screen",
      "Tap on product name referring to lipstick",
      "add the product as favorite",
      "add to cart",
      "Verify lipstick is added to cart",
      "Tap on Continue inorder to checkout",
      "Tap on Complete Order",
      "Verify order created success message"
    ]

    for step in testSteps {
      do {
        try await app.executeAIStep(step)
      } catch {
        XCTFail("Step '\(step)' failed with error: \(error)")
      }
    }
  }

  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}

extension String {
  func slice(from: String, to: String) -> String? {
    guard let start = range(of: from)?.upperBound else { return nil }
    guard let end = range(of: to, range: start..<endIndex)?.lowerBound else { return nil }
    return String(self[start..<end])
  }
}
