//
//  ShoppingUITests.swift
//  ShoppingUITests
//
//  Created by Berkay Sancar on 26.07.2024.
//

import XCTest

final class ShoppingUITests: XCTestCase {

  func testDirectlyWithoutBDD() async {
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

  func testPurchaseFlow() async {
    let scenarios = ScenarioOperation.ScenarioReader(fileName: "scenarios")
    guard let scenario = scenarios.first(where: { $0.name == "Purchase Flow" }) else {
      XCTFail("Purchase Flow scenario not found")
      return
    }
    await ScenarioOperation.processAndExecuteScenario(scenario: scenario)
  }

  func testHomeScreenFilterIsApplied() async {
    let scenarios = ScenarioOperation.ScenarioReader(fileName: "scenarios")
    guard let scenario = scenarios.first(where: { $0.name == "Apply Filter In App Home Screen" }) else {
      XCTFail("Apply Filter In App Home Screen scenario not found")
      return
    }
    await ScenarioOperation.processAndExecuteScenario(scenario: scenario)
  }
}
