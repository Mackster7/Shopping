//
//  ElementTypeInfo.swift
//  ShoppingUITests
//
//  Created by Syed Mansoor on 23/04/25.
//

import Foundation
import XCTest
// Define all supported element types
struct ElementTypeInfo {
    let queryName: String    // Name used in XCUIElement queries like "buttons"
    let elementGetter: (XCUIApplication) -> ((String) -> XCUIElement)  // Function to get the element
}

// Map of supported element types
let elementTypesMap: [String: ElementTypeInfo] = [
    "buttons": ElementTypeInfo(
        queryName: "buttons",
        elementGetter: { app in { identifier in app.buttons[identifier] } }
    ),
    "textFields": ElementTypeInfo(
        queryName: "textFields",
        elementGetter: { app in { identifier in app.textFields[identifier] } }
    ),
    "staticTexts": ElementTypeInfo(
        queryName: "staticTexts",
        elementGetter: { app in { identifier in app.staticTexts[identifier] } }
    ),
    "images": ElementTypeInfo(
        queryName: "images",
        elementGetter: { app in { identifier in app.images[identifier] } }
    ),
    "switches": ElementTypeInfo(
        queryName: "switches",
        elementGetter: { app in { identifier in app.switches[identifier] } }
    ),
    "segmentedControls": ElementTypeInfo(
        queryName: "segmentedControls",
        elementGetter: { app in { identifier in app.segmentedControls[identifier] } }
    ),
    "sliders": ElementTypeInfo(
        queryName: "sliders",
        elementGetter: { app in { identifier in app.sliders[identifier] } }
    ),
    "steppers": ElementTypeInfo(
        queryName: "steppers",
        elementGetter: { app in { identifier in app.steppers[identifier] } }
    ),
    "pickers": ElementTypeInfo(
        queryName: "pickers",
        elementGetter: { app in { identifier in app.pickers[identifier] } }
    ),
    "links": ElementTypeInfo(
        queryName: "links",
        elementGetter: { app in { identifier in app.links[identifier] } }
    ),
    "navigationBars": ElementTypeInfo(
        queryName: "navigationBars",
        elementGetter: { app in { identifier in app.navigationBars[identifier] } }
    ),
    "tabBars": ElementTypeInfo(
        queryName: "tabBars",
        elementGetter: { app in { identifier in app.tabBars[identifier] } }
    ),
    "tables": ElementTypeInfo(
        queryName: "tables",
        elementGetter: { app in { identifier in app.tables[identifier] } }
    ),
    "cells": ElementTypeInfo(
        queryName: "cells",
        elementGetter: { app in { identifier in app.cells[identifier] } }
    ),
    "scrollViews": ElementTypeInfo(
        queryName: "scrollViews",
        elementGetter: { app in { identifier in app.scrollViews[identifier] } }
    )
    // Add more element types as needed
]
