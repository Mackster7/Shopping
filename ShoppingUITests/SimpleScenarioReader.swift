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


class ScenarioOperation {
  static func ScenarioReader(fileName: String) -> [TestScenario] {
    guard let path = Bundle(for: ShoppingUITests.self).path(forResource: fileName, ofType: "txt"),
          let content = try? String(contentsOfFile: path) else {
      print("Could not find or load file: \(fileName).txt")
      return []
    }

    let scenarios = content.components(separatedBy: "Scenario:")
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

  static func processAndExecuteScenario(scenario: TestScenario) async {
    let processedSteps = removeBDDKeywords(from: scenario.steps)
    let cleanScenario = TestScenario(name: scenario.name, steps: processedSteps)
    print("Executing scenario: \(scenario.name)")
    print("Steps: \(processedSteps)")
    await executeScenario(cleanScenario)
  }

  static func removeBDDKeywords(from steps: [String]) -> [String] {
    return steps.map { step in
      var cleanStep = step
      if cleanStep.hasPrefix("Given ") {
        cleanStep = String(cleanStep.dropFirst(6)).trimmingCharacters(in: .whitespaces)
      } else if cleanStep.hasPrefix("When ") {
        cleanStep = String(cleanStep.dropFirst(5)).trimmingCharacters(in: .whitespaces)
      } else if cleanStep.hasPrefix("Then ") {
        cleanStep = String(cleanStep.dropFirst(5)).trimmingCharacters(in: .whitespaces)
      }
      return cleanStep
    }
  }

  static func executeScenario(_ scenario: TestScenario) async {
    let app = await XCUIApplication()
    await app.launch()
    print("🧪 Running scenario: \(scenario.name)")
    for (stepIndex, step) in scenario.steps.enumerated() {
      do {
        print("📝 Step \(stepIndex + 1): \(step)")
        try await app.executeAIStep(step)
        print("✅ Step completed successfully")
      } catch {
        let errorMessage = "Step '\(step)' failed with error: \(error)"
        print("❌ \(errorMessage)")
        XCTFail(errorMessage)
        return // Stop execution on first failure
      }
    }
    print("🎉 Scenario '\(scenario.name)' completed successfully")
  }
}
