//
//  UITestError.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 23/04/25.
//

import Foundation
import XCTest

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
