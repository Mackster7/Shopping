//
//  XCUICoordinateParser.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 21/05/25.
//

import Foundation
import XCTest

class XCUICoordinateParser {
    
    /// Converts a coordinate interaction string to an XCUIElement
    /// - Parameter coordinateString: String like "app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: 175, dy: 315)).tap()"
    /// - Returns: XCUIElement at the specified coordinates
    static func parseToElement(coordinateString: String) -> XCUIElement? {
        // Extract the coordinates using regular expressions
        guard let coordinates = extractCoordinates(from: coordinateString) else {
            print("Failed to extract coordinates from string")
            return nil
        }
        
        let app = XCUIApplication()
        
        // Search for elements at the specified coordinates
        // We'll check elements within a small tolerance range around the target point
        let elementsAtPoint = findElementsAt(coordinates: coordinates, app: app)
        
        // Return the most specific (deepest) element found
        return elementsAtPoint.first
    }
    
    /// Extract coordinate values from the string
    private static func extractCoordinates(from string: String) -> CGPoint? {
        // Regular expression to find dx and dy values in the withOffset part
        let pattern = "withOffset\\(CGVector\\(dx: ([0-9.]+), dy: ([0-9.]+)\\)\\)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let matches = regex?.matches(in: string, options: [], range: NSRange(string.startIndex..., in: string)),
              let match = matches.last, // Take the last withOffset call in case there are multiple
              match.numberOfRanges == 3 else {
            return nil
        }
        
        // Extract dx and dy values
        guard let dxRange = Range(match.range(at: 1), in: string),
              let dyRange = Range(match.range(at: 2), in: string),
              let dx = Double(string[dxRange]),
              let dy = Double(string[dyRange]) else {
            return nil
        }
        
        return CGPoint(x: dx, y: dy)
    }
    
    /// Find UI elements at the specified coordinates
    private static func findElementsAt(coordinates: CGPoint, app: XCUIApplication) -> [XCUIElement] {
        // Get all elements in the app hierarchy
        let allElements = app.descendants(matching: .any)
        
        // Filter elements that contain the target point
        let elementsAtPoint = allElements.allElementsBoundByIndex.filter { element in
            let frame = element.frame
            return frame.contains(coordinates)
        }
        
        // Sort by area (smallest first) to get the most specific element
        return elementsAtPoint.sorted { $0.frame.width * $0.frame.height < $1.frame.width * $1.frame.height }
    }
    
    /// Perform a hit test to get the element at the specified coordinates
    /// - Parameters:
    ///   - coordinates: The coordinates to test
    ///   - app: The XCUIApplication instance
    /// - Returns: The element at the specified coordinates, or nil if none found
    static func hitTest(at coordinates: CGPoint, in app: XCUIApplication) -> XCUIElement? {
        let hitPoint = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: coordinates.x, dy: coordinates.y))
        
        // This is a workaround since XCUICoordinate doesn't have a direct hitTest method
        // We'll use private APIs to get the element at the hit point
        
        // For demonstration purposes, we'll use our findElementsAt method
        return findElementsAt(coordinates: coordinates, app: app).first
    }
    
    /// Helper method to use the parser
    /// - Parameter coordinateString: The coordinate interaction string
    /// - Returns: An XCUIElement that can be interacted with
    static func elementFromCoordinateString(_ coordinateString: String) -> XCUIElement? {
        guard let element = parseToElement(coordinateString: coordinateString) else {
            print("Failed to parse coordinate string to element")
            return nil
        }
        return element
    }
    
    /// Alternative approach that just extracts the coordinates and then performs a hit test
    static func directHitTestFromString(_ coordinateString: String) -> XCUIElement? {
        guard let coordinates = extractCoordinates(from: coordinateString) else {
            print("Failed to extract coordinates from string")
            return nil
        }
        
        return hitTest(at: coordinates, in: XCUIApplication())
    }
}
