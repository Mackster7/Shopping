//
//  SimpleScenarioReader.swift
//  Shopping
//
//  Created by Syed Mansoor on 03/06/25.
//

import Foundation
import XCTest

// MARK: - Test Scenario Structure
struct TestScenario {
    let name: String
    let steps: [String]
}


class SimpleScenarioReader {
    static func SimpleScenarioReader(fileName: String) -> [TestScenario] {
        guard let path = Bundle(for: ShoppingUITests.self).path(forResource: fileName, ofType: "txt"),
              let content = try? String(contentsOfFile: path) else {
            print("Could not find or load file: \(fileName).txt")
            return []
        }

        let scenarios = content.components(separatedBy: "---SCENARIO---")
            .compactMap { scenarioBlock -> TestScenario? in
                let lines = scenarioBlock.trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: .newlines)
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

                guard !lines.isEmpty else { return nil }

                let name = lines[0].trimmingCharacters(in: .whitespaces)
                let steps = Array(lines.dropFirst()).map { $0.trimmingCharacters(in: .whitespaces) }

                return TestScenario(name: name, steps: steps)
            }

        return scenarios
    }
}
