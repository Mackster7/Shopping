//
//  AITestHelper.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 19/04/25.
//

import Foundation
import XCTest

/**
 * Represents different types of test steps in UI automation
 */
public enum StepType {
    case validateScreen      // For steps that verify UI state or screen content
    case performElementAction // For steps that interact with UI elements
}

/// AITestHelper provides AI assistance for UI test automation
class AITestHelper {
    
    /**
     * Determines the type of step based on step description
     * - Parameter stepDescription: The description of the test step
     * - Returns: The classified step type (validateScreen or performElementAction)
     */
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
        
        // Clean up response and handle classification
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
    
    /// Generates element queries based on app state and test steps
    /// - Parameters:
    ///   - step: The test step description
    ///   - appDescription: The current app debug description
    /// - Returns: AI-suggested element query
    static func generateElementQuery(for step: String, appDescription: String) async -> String {
        
        let actionPrompt = """
            You are a senior iOS developer and you are supposed to return only XCUIElement query with action 
            if required as per step. If you didn't find the target element just return 'Not Found'.
            step: \(step); description: \(appDescription)
            """
        
        return await AICall(prompt: actionPrompt).getPromptResponse()
    }
    
    /// Extracts element identifier from AI response
    /// - Parameters:
    ///   - responseText: The AI-generated response
    ///   - elementType: The type of UI element (e.g., "buttons", "textFields")
    /// - Returns: The extracted element identifier or nil if not found
    static func extractElementIdentifier(from responseText: String, elementType: String) -> String? {
        return responseText.slice(from: ".\(elementType)[\"", to: "\"]")
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

extension XCUIApplication {
    /// Executes an AI-assisted step in the test
    /// - Parameters:
    ///   - step: Description of the test step
    ///   - timeout: Wait time before and after the step execution (default: 5 seconds)
    /// - Returns: Success or failure of the step
    @discardableResult
    func executeAIStep(_ step: String, timeout: TimeInterval = 2) async throws {
        // Wait for UI to stabilize
        Thread.sleep(forTimeInterval: timeout)
        
        // Get app state and generate AI response
        let appState = self.debugDescription
        let stepType = await AITestHelper.getStepType(for: step)
        
        switch stepType {
        case .performElementAction:
            let aiResponse = await AITestHelper.generateElementQuery(for: step, appDescription: appState)
            // Handle failure case
            if aiResponse.contains("Not Found") {
                throw UITestError.elementNotFound(step: step)
            }
            
            // Handle different element types
            if aiResponse.contains(".buttons[\"") {
                if let buttonName = AITestHelper.extractElementIdentifier(from: aiResponse, elementType: "buttons") {
                    if self.buttons[buttonName].exists {
                        self.buttons[buttonName].tap()
                        Thread.sleep(forTimeInterval: timeout)
                    } else {
                        throw UITestError.elementExists(elementType: "button", identifier: buttonName)
                    }
                }
            } else if aiResponse.contains(".textFields[\"") {
                if let textFieldName = AITestHelper.extractElementIdentifier(from: aiResponse, elementType: "textFields") {
                    if self.textFields[textFieldName].exists {
                        self.textFields[textFieldName].tap()
                        Thread.sleep(forTimeInterval: timeout)
                    } else {
                        throw UITestError.elementExists(elementType: "text field", identifier: textFieldName)
                    }
                }
            } else if aiResponse.contains(".staticTexts[\"") {
                if let textName = AITestHelper.extractElementIdentifier(from: aiResponse, elementType: "staticTexts") {
                    if self.staticTexts[textName].exists {
                        self.staticTexts[textName].tap()
                        Thread.sleep(forTimeInterval: timeout)
                    } else {
                        throw UITestError.elementExists(elementType: "static text", identifier: textName)
                    }
                }
            } else {
                throw UITestError.unsupportedElementType(aiResponse: aiResponse)
            }
            
        case .validateScreen:
            let isTargetScreen = await AITestHelper.verifyUserIsInTargetScreen(for: step, appDescription: appState)
            guard isTargetScreen else {
                XCTFail("Failed to verify target screen for step: \(step)")
                return
            }
        default:
            XCTFail("Failed to classify the step: \(step)")
        }
    }
}

enum UITestError: Error, CustomStringConvertible {
    case elementNotFound(step: String)
    case elementExists(elementType: String, identifier: String)
    case unsupportedElementType(aiResponse: String)
    
    var description: String {
        switch self {
        case .elementNotFound(let step):
            return "Failed to find element for step: \(step)"
        case .elementExists(let elementType, let identifier):
            return "The \(elementType) with identifier '\(identifier)' doesn't exist"
        case .unsupportedElementType(let aiResponse):
            return "Unsupported element type in AI response: \(aiResponse)"
        }
    }
}
