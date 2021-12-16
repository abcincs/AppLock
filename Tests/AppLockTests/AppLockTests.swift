import XCTest
@testable import AppLock

final class AppLockTests: XCTestCase {
    let view = AppLockView(rightPin: "1975", completion: { result in })
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertNotEqual(view.fingerPrint, UIImage(systemName: "lock.shield.fill"))
        XCTAssert(view.correctPin == "1975")
        
        
    }
//
    static var allTests = [
        ("testExample", testExample),
    ]
}
