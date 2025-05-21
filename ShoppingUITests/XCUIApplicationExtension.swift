//
//  XCUIApplicationExtension.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 23/04/25.
//

import Foundation
import XCTest

extension XCUIApplication {
    
    func executeAIStep(_ step: String, timeout: TimeInterval = 2) async throws {
        // Wait for UI to stabilize
        Thread.sleep(forTimeInterval: timeout)
        let screenDescription = self.debugDescription
        let stepType = await AITestHelper.getStepType(for: step)
        print("Step Type: \(String(describing: stepType))")
        
        switch stepType {
        case .performElementAction:
            let aiResponse = await AITestHelper.generateElementQuery(for: step, appDescription: screenDescription)
            print("Perform Element Action Response : \(aiResponse)")
            
            if aiResponse.contains("Not Found") {
                XCTFail("Failed to generate element query for step \(step)")
            }
            guard let element = XCUICoordinateParser.directHitTestFromString(aiResponse) else {
                XCTFail("Failed to parse element: \(aiResponse)")
                return
            }
            guard element.waitForExistence(timeout: 2) else {
                XCTFail("Failed to find the element \(element)")
                return
            }
            element.tap()
            
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
}
