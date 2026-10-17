//
//  BookNestUITests.swift
//  BookNestUITests
//
import XCTest

final class BookNestUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLoginScreenAppears() throws {
        let app = XCUIApplication()
        app.launch()
       
        // Check that the login screen elements exist
        XCTAssertTrue(app.textFields["Enter your name"].exists)
        XCTAssertTrue(app.buttons["Continue"].exists)
        XCTAssertTrue(app.staticTexts["BookNest"].exists)
    }
   
    func testLoginAsBorrower() throws {
        let app = XCUIApplication()
        app.launch()
       
        let nameField = app.textFields["Enter your name"]
        nameField.tap()
        nameField.typeText("TestUser")
       
        app.buttons["Continue"].tap()
       
        // After login, the Books tab should be visible
        XCTAssertTrue(app.tabBars.buttons["Books"].exists)
    }
   
    func testSettingsTab() throws {
        let app = XCUIApplication()
        app.launch()
       
        // Login
        let nameField = app.textFields["Enter your name"]
        nameField.tap()
        nameField.typeText("Test")
        app.buttons["Continue"].tap()
       
        // Go to Settings tab
        app.tabBars.buttons["Settings"].tap()
       
        // Wait a moment and check for Dark Mode toggle instead of navigation bar
        let darkModeToggle = app.switches["Dark Mode"]
        XCTAssertTrue(darkModeToggle.waitForExistence(timeout: 3))
    }
}
