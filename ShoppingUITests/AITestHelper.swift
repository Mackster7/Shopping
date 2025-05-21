//
//  AITestHelper.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 19/04/25.
//

import Foundation
import XCTest

class AITestHelper {
  static func getStepType(for stepDescription: String) async -> StepType? {
    let classificationPrompt = """
            You are an AI assistant helping with UI test automation.
            Classify the following test step into one of two categories:
            1. "performElementAction" - if the step involves interacting with an element (tap, click, swipe, type, etc.)
            2. "validateScreen" - if the step involves verifying UI state, screen content, or validating information

            Only respond with exactly one of these two options: "performElementAction" or "validateScreen"

            Test step: \(stepDescription)
            """
    let response = await AICall(prompt: classificationPrompt).getPromptResponse()
    let cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
    switch cleanedResponse {
    case "performElementAction":
      return .performElementAction
    case "validateScreen":
      return .validateScreen
    default:
      XCTFail("Failed to classify the step: \(stepDescription). Received: \(cleanedResponse)")
      return nil
    }
  }

  static func generateElementQuery(for step: String, appDescription: String) async -> String {
    let actionPrompt = """
    You are an expert iOS UI testing assistant. Your sole task is to generate a single line of XCUIAutomation code to interact with an element based on the provided step and element details. Always use coordinate-based interaction regardless of other available selectors. Do not include any code blocks, language identifiers, or explanations in your response. If the target element cannot be identified, return only the text 'Not Found'.
    Here is an examples:
    Step: Click on Buy button 
    Element Details: Button, 0x105e738a0, {{180.3, 509.3}, {41.7, 24.3}}, label: 'Login'
    Button coordinates are: {180.3, 509.3}
    Output: app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 180.3, dy: 509.3)).tap()
    step: \(step); description: \(appDescription)
    """
    return await AICall(prompt: actionPrompt).getPromptResponse()
  }

  static func verifyUserIsInTargetScreen(for step: String, appDescription: String) async -> Bool {
    let prompt = """
        You are an iOS UI testing assistant. Given the app's current state and a validation step, determine whether the user is on the expected screen.
        Validation step: \(step)
        App description: \(appDescription)
        Analyze the app description for UI elements, navigation bars, titles, and content that would confirm if the user is on the expected screen mentioned in the validation step.
        Respond with exactly one of these two answers:
        - "true" if the app description shows the user is on the expected screen
        - "false" if the app description shows the user is NOT on the expected screen
        Do not provide any other text in your response.
        """
    let response = await AICall(prompt: prompt).getPromptResponse()
    return (response.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true")
  }
}
