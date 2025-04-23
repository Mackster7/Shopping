//
//  XCUIApplicationExtension.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 23/04/25.
//

import Foundation
import XCTest

extension XCUIApplication {

  @discardableResult
  func executeAIStep(_ step: String, timeout: TimeInterval = 2) async throws {
    // Wait for UI to stabilize
    Thread.sleep(forTimeInterval: timeout)
    let screenDescription = self.debugDescription
    let stepType = await AITestHelper.getStepType(for: step)
    print("Step Type: \(stepType)")

    switch stepType {
    case .performElementAction:
      let aiResponse = await AITestHelper.generateElementQuery(for: step, appDescription: screenDescription)
      var targetElement: XCUIElement?
      print("Perform Element Action Response : \(aiResponse)")
      // Handle failure case
      if aiResponse.contains("Not Found") {
        throw UITestError.elementNotFound(step: step)
      }

      guard try handleElement(from: aiResponse, timeout: timeout) else {
        XCTFail("Failed to handle element for step: \(step)")
        return
      }

    case .validateScreen:
      let isTargetScreen = await AITestHelper.verifyUserIsInTargetScreen(for: step, appDescription: screenDescription)
      print("Validate Screen Response : \(isTargetScreen)")
      guard isTargetScreen else {
        XCTFail("Failed to verify target screen for step: \(step)")
        return
      }
    default:
      XCTFail("Failed to classify the step: \(step)")
    }
  }

  func handleElement(from aiResponse: String, timeout: TimeInterval) throws -> Bool {
    // Detect which element type was mentioned in the AI response
    for (queryName, elementInfo) in elementTypesMap {
      let searchPattern = ".\(queryName)[\""

      if aiResponse.contains(searchPattern) {
        if let identifier = extractElementIdentifier(from: aiResponse, elementType: queryName) {
          // Get the element using the associated getter function
          let element = elementInfo.elementGetter(self)(identifier)

          if element.exists {
            // Perform the action (tap by default)
            element.tap()
            Thread.sleep(forTimeInterval: timeout)
            return true
          } else {
            return false
          }
        }
      }
    }

    // No supported element type found
    throw UITestError.unsupportedElementType(aiResponse: aiResponse)
  }

  func extractElementIdentifier(from responseText: String, elementType: String) -> String? {
    return responseText.slice(from: ".\(elementType)[\"", to: "\"]")
  }
}
