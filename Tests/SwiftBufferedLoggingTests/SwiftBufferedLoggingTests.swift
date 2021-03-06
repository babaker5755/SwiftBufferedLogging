import XCTest
@testable import SwiftBufferedLogging

final class SwiftBufferedLoggingTests: XCTestCase {
    
    static var sentLogs : [String] = []
    static var failedLogs : [String] = []
    
    var logger : SwiftBufferedLogging!
    
    var success : Bool = true
    var shouldSkipCallingCompletion : Bool = false
    
    /// Tests timer by logging once and checking
    /// if it has been sent after logOption.saveTime
    func testSimpleTimer() {
        log("test")
        wait(for: 6)
        XCTAssertEqual(SwiftBufferedLoggingTests.sentLogs, ["test"])
    }
    
    /// Test max buffer size by adding 1 more than buffer size
    /// and checking that they are sent before logOption.saveTime
    func testSimpleMaxBuffer() {
        
        // default max buffer size is 5
        let testArray = ["test", "test1", "test2", "test3", "test4", "test5"]
        let resultArray = ["test", "test1", "test2", "test3", "test4"]
        testArray.forEach { log($0) }
        
        wait(for: 1)
        
        XCTAssertEqual(SwiftBufferedLoggingTests.sentLogs, resultArray)
    }
    
    /// Tests min buffer by adding 1 below min buffer size, and checking that
    /// they have not been sent after logOption.saveTime has passed
    func testSimpleMinBuffer() {
        
        // min buffer size = 5
        let logOptions = LogOptions(saveTime: 5, maxBufferSize: 10, minBufferSize: 5, maxRetries: 0)
        logger = SwiftBufferedLogging(delegate: self, logOptions: logOptions)
        
        let testArray = ["test", "test1", "test2", "test3"]
        
        testArray.forEach { log($0) }
        
        wait(for: 6)
        
        XCTAssertEqual(SwiftBufferedLoggingTests.sentLogs, [])
        
    }
    
    /// Tests max retry by setting maxRetries to 2,
    /// and adding logs that will fail to upload
    func testRetry() {
        
        let logOptions = LogOptions(saveTime: 1, maxBufferSize: 100, minBufferSize: 1, maxRetries: 2)
        logger = SwiftBufferedLogging(delegate: self, logOptions: logOptions)
        
        success = false
        
        let testArray = ["test", "test1", "test2", "test3", "test4", "test5"]
        testArray.forEach { log($0) }
        
        wait(for: 3)
        
        success = true
        
        wait(for: 10)
        
        XCTAssertEqual(SwiftBufferedLoggingTests.sentLogs, testArray)
        XCTAssert(Batch.batches.isEmpty)
    }
    
    /// Tests max retry by setting maxRetries to 2,
    /// and adding logs that will fail to upload
    func testMaxRetry() {
        
        let logOptions = LogOptions(saveTime: 1, maxBufferSize: 100, minBufferSize: 1, maxRetries: 2)
        logger = SwiftBufferedLogging(delegate: self, logOptions: logOptions)
        
        success = false
        
        let testArray = ["test", "test1", "test2", "test3", "test4", "test5"]
        testArray.forEach { log($0) }
        
        wait(for: 10)
        
        XCTAssertEqual(SwiftBufferedLoggingTests.failedLogs, testArray)
        XCTAssert(Batch.batches.isEmpty)
    }
    
}

//  MARK: User Delegate Function
extension SwiftBufferedLoggingTests : SwiftBufferedLogDelegate {
    
    func sendLogs(_ logs: [Log], completion: ((Bool) -> Void)) {
        print("adding logs to sent logs", logs.map { $0.message })
        if success {
            SwiftBufferedLoggingTests.sentLogs.append(contentsOf: logs.map { $0.message })
        }
        completion(success)
    }
    
    func didFailToSendLogs(_ logs: [Log]) {
        print("Logs failed to send after retrying: \(logs.map { $0.message + "\n" })")
        SwiftBufferedLoggingTests.failedLogs.append(contentsOf: logs.map { $0.message })
    }
    
}



// MARK: Test Helper Functions
extension SwiftBufferedLoggingTests {
    
    static var allTests = [
        ("testSimpleTimer", testSimpleTimer),
        ("testSimpleMaxBuffer", testSimpleMaxBuffer),
        ("testSimpleMinBuffer", testSimpleMinBuffer)
    ]
    
    override func setUp() {
        wait(for: 10)
        Batch.batches = []
        setupLogger()
    }
    
    override func tearDown() {
        wait(for: 10)
        Batch.batches = []
        SwiftBufferedLoggingTests.failedLogs = []
        SwiftBufferedLoggingTests.sentLogs = []
    }
    
}

// MARK: Wait
extension XCTestCase {

  func wait(for duration: TimeInterval) {
    let waitExpectation = expectation(description: "Waiting")

    let when = DispatchTime.now() + duration
    DispatchQueue.main.asyncAfter(deadline: when) {
      waitExpectation.fulfill()
    }

    // We use a buffer here to avoid flakiness with Timer on CI
    waitForExpectations(timeout: duration + 0.5)
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
