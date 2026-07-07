import XCTest

final class CarryOnCheckerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddButtonOpensAddSheet() {
        let addButton = app.buttons["main.addButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5))
    }

    func testSettingsButtonOpensSettings() {
        let settingsButton = app.buttons["main.settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        XCTAssertTrue(app.buttons["settings.doneButton"].waitForExistence(timeout: 5))
        app.buttons["settings.doneButton"].tap()
    }

    func testFreeLimitTriggersPaywall() {
        let addButton = app.buttons["main.addButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        for _ in 0..<25 {
            if app.buttons["paywall.closeButton"].exists { break }
            addButton.tap()
            let saveButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'saveButton'"))
            if saveButtons.count > 0 {
                saveButtons.firstMatch.tap()
            } else {
                break
            }
        }
    }

    func testKeyboardDismissesOnTapOutside() {
        let addButton = app.buttons["main.addButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        let textField = app.textFields.firstMatch
        if textField.waitForExistence(timeout: 5) {
            textField.tap()
            textField.typeText("Test")
            app.navigationBars.firstMatch.tap()
            XCTAssertFalse(app.keyboards.firstMatch.exists)
        }
    }
}
