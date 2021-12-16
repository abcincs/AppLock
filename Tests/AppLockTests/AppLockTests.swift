import XCTest
@testable import AppLock

final class AppLockTests: XCTestCase {
    let oldView = AppLockView(rightPin: "1975", completion: { result in })
    let newView = AppLockView(pincode: AppLockView.PinCode(1975)) { result in }
    
    func testView() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertNotEqual(oldView.fingerPrint, UIImage(systemName: "lock.shield.fill"))
        XCTAssert(oldView.correctPin == AppLockView.PinCode("1975"))
        
        // New View
        XCTAssertNotEqual(newView.fingerPrint, UIImage(systemName: "lock.shield.fill"))
        XCTAssert(newView.correctPin == AppLockView.PinCode("1975"))
        
    }
    
    func testPins() {
        XCTAssert(AppLockView.PinCode(20).isValid == false)
        
        XCTAssert(AppLockView.PinCode(123456).isValid == true)
        
        XCTAssert(AppLockView.PinCode("123456").isValid == true)
        
        XCTAssert(AppLockView.PinCode("1234567").isValid == false)
        
        XCTAssert(AppLockView.PinCode(1234567).isValid == false)
    }

    
    static var allTests = [
        ("testView", testView),
        ("testPins", testPins),
    ]
}
