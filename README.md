# SwiftBufferedLogging

A description of this package.


## Usage

### Set up logging class
```swift
import SwiftBufferedLogging

class Logger {

    private static var logger : SwiftBufferedLogging!

    func init() {
        logger = SwiftBufferedLogging(delegate: self)
    }

    /// Log
    /// - Parameter message: Info to be logged
    public static func log(_ message: String) {
        
        let metadata: [String : Any] = [
            "deviceModel": "iPad 5",
            "userId": "17939101",
            "isTest": true
        ]
        
        let log = Log(message: message, level: .debug, metadata: metadata)
        
        logger.log(log)
    }
}

extension Logger : SwiftBufferedLogDelegate {
    
    func sendLogs(_ logs: [Log], completion: ((Bool) -> Void)) {
        Network.sendLogs(logs: logs) { result in
           switch result {
           case .success(let result):
               completion(true)
           case .failure(let error):
               completion(false)
           }
        }
    }
    
    func didFailToSendLogs(_ logs: [Log]) {
        print("Logs failed to send after retrying: \(logs.map { $0.message + "\n" })")
        
    }
    
}
```
### Usage in app
```swift 
func viewDidLoad() {
    super.viewDidLoad()
    
    Logger.log(
}
```
