import XCTest
@testable import SwiftBufferedLogging

final class SwiftBufferedLoggingTests: XCTestCase {
    
    func testColorRedEqual() {
        let color = SwiftBufferedLogging.colorFromHexString("FF0000")
        XCTAssertEqual(color, .red)
    }
    
    static var allTests = [
        ("testColorRedEqual", testColorRedEqual),
    ]
}
