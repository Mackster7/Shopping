//
//  AICall.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 19/04/25.
//

import Foundation
import GoogleGenerativeAI

class AICall {
    let apiKey = "AIzaSyDd1xLBR0oBBiUPvvpbueT7bIC1AnDcou8"
    var prompt: String
    
    init(prompt: String) {
        self.prompt = prompt
    }

    public func getPromptResponse() async -> String {
        let model = GenerativeModel(name: "gemini-2.5-flash-preview-04-17", apiKey: apiKey)
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                return text
            } else {
                return "Empty"
            }
        } catch {
            print("Error generating content: \(error)")
            return "Error"
        }
    }
}
