**AI-Powered UI Test Automation**

This project showcases an innovative approach to UI testing by leveraging generative AI to automate test cases. Instead of writing and maintaining rigid test scripts, this framework uses natural language test steps defined in a simple text file. An AI agent then interprets these steps and executes them by interacting with the app's UI in real-time.

**Overview**

The core of this project is to create a system where UI tests are written in a human-readable format, which are then dynamically executed by an AI. This eliminates the need for hardcoded element identifiers (like accessibility IDs or XPath) and makes the tests more resilient to UI changes. The AI analyzes the screen's view hierarchy to identify the correct UI element for each step and performs the required action, such as tapping a button or verifying on-screen text.

**How it Works**

The test automation process follows a clear, multi-step workflow designed to interpret and execute UI test scenarios dynamically.

Scenario Definition: Test cases are written as BDD-style scenarios in a .txt file. Each scenario consists of a name and a series of steps using Given, When, and Then keywords.

Scenario Parsing: The ScenarioOperation class reads and parses the scenarios.txt file. It extracts the scenario name and the individual steps, cleaning them by removing the BDD keywords to get the core action or validation.

Step Classification: For each step, the AITestHelper sends a prompt to a generative AI model to classify the step as either a performElementAction (e.g., tapping a button) or a validateScreen (e.g., verifying a success message).

**AI-Powered Execution:**

For performElementAction steps, the AITestHelper sends another prompt to the AI, including the natural language step and the app's current UI hierarchy. The AI returns the coordinates of the target UI element. The XCUICoordinateParser then uses these coordinates to perform a tap action.

For validateScreen steps, the AI receives the validation step and the UI hierarchy to confirm if the current screen matches the expected state. It returns a simple "true" or "false".

Test Execution and Reporting: The XCUIApplicationExtension manages the execution of each step. The results are logged, and if any step fails, the test is stopped, and an XCTFail message is recorded.

**Future Scope**

This project serves as a proof-of-concept and can be extended with several enhancements:

Support for More Gestures: Beyond tapping, the framework can be expanded to support other UI interactions like swiping, scrolling, and text input.

Enhanced Element Identification: While coordinate-based interaction is robust, combining it with other selectors like accessibility identifiers could improve accuracy.

Improved Error Handling: More sophisticated error recovery mechanisms could be implemented, allowing the AI to retry a step or try an alternative action if the initial attempt fails.
