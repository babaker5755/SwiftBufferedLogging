import XCTest
@testable import SwiftBufferedLogging

final class SwiftBufferedLoggingTests: XCTestCase {
    
    static var sentLogs : [String] = []
    
    var logger : SwiftBufferedLogging!
    
    /// Tests timer by logging once
    /// and checking if it has been sent
    /// after logOption.saveTime
    func simpleTimerTest() {
        log("test")
        performIn(6) {
            XCTAssertEqual(SwiftBufferedLoggingTests.sentLogs, ["test"])
        }
    }
    
    /// Test max buffer size
    /// by adding 1 more than buffer size
    /// and checking that they are sent
    /// before logOption.saveTime
    func simpleMaxBufferTest() {
        
        // max buffer size is 5
        let testArray = ["test", "test1", "test2", "test3", "test2", "test3"]
        
        testArray.forEach { log($0) }
        
        performIn(1) {
            XCTAssertEqual(SwiftBufferedLoggingTests.sentLogs, ["test"])
        }
    }
    
    /// Tests min buffer by adding 1 below
    /// min buffer size, and checking that
    /// they have not been sent after
    /// logOption.saveTime has passed
    func simpleMinBufferTest() {
        
        // min buffer size = 5
        let logOptions = LogOptions(saveTime: 5, maxBufferSize: 10, minBufferSize: 5, maxRetries: 0)
        logger = SwiftBufferedLogging(delegate: self, logOptions: logOptions)
        
        let testArray = ["test", "test1", "test2", "test3"]
        
        testArray.forEach { log($0) }
        
        performIn(6) {
            XCTAssertEqual(SwiftBufferedLoggingTests.sentLogs, [])
        }
    }
    
    
}


// MARK: Test Helper Functions
extension SwiftBufferedLoggingTests {
    
    /// All tests
    static var allTests = [
        ("simpleTimerTest", simpleTimerTest),
        ("simpleMaxBufferTest", simpleMaxBufferTest),
        ("simpleMinBufferTest", simpleMinBufferTest)
    ]
    
    /// Set up
    override func setUp() {
        print("setting for next test")
        setupLogger()
    }
    
    /// Timer
    func performIn(_ seconds: Double, completion: @escaping (() -> Void)) {
        if #available(iOS 10.0, *) {
            _ = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
                completion()
            }
        }
    }
}



//MARK: User Set Up Functions
extension SwiftBufferedLoggingTests {
    
    /// Sets up an instance of logger
    /// should be performed before each test
    func setupLogger() {
        let logOptions = LogOptions(saveTime: 5, maxBufferSize: 5, minBufferSize: 1, maxRetries: 0)
        logger = SwiftBufferedLogging(delegate: self, logOptions: logOptions)
    }
    
    
    /// Log
    /// - Parameter message: Info to be logged
    func log(_ message: String) {
        
        let metadata: [String : Any] = [
            "deviceModel": "iPad 5",
            "userId": "17939101",
            "isTest": true
        ]
        
        let log = Log(message: message, level: .debug, metadata: metadata)
        
        logger.log(log)
    }
    
}


//  MARK: User Delegate Function
extension SwiftBufferedLoggingTests : SwiftBufferedLogDelegate {
    
    func sendLogs(_ logs: [Log], completion: ((Bool) -> Void)) {
        print("adding logs to sent logs", logs.map { $0.message })
        SwiftBufferedLoggingTests.sentLogs.append(contentsOf: logs.map { $0.message })
        completion(true)
    }
    
    func didFailToSendLogs(_ logs: [Log]) {
        print("Logs failed to send after retrying: \(logs.map { $0.message + "\n" })")
        
    }
    
}
