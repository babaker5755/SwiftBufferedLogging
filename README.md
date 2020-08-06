# SwiftBufferedLogging

### Log your data in batches


Integrate SwiftBufferedLogging into your logging class to easily send logs in batches instead of one at a time.

Specify options to control how often you send data to the server, how many retry attempts, and how many at a time. 

Implement SwiftBufferedLogDelegate and create the sendLogs function that will be called when the logs are ready to be sent to the server, 
and in following calls in the case of failure. Ensure you call completion(true) on success, and completion(false) on failure in this function. 

Logs that have failed to send the specifed number of retries will be sent to 'didFailToSendLogs'.


## Usage

### Set up logging class
```swift
import SwiftBufferedLogging

class Logger {

    private static var instance = Logger()
    private var logger : SwiftBufferedLogging!
    
    /// Create an instance of SwiftBufferedLogging
    /// and specify options here.
    init() {
        let options = LogOptions(saveTime: 10, maxBufferSize: 10, minBufferSize: 5, maxRetries: 3)
        logger = SwiftBufferedLogging(delegate: self, logOptions: options)
    }

    /// Log
    /// Create a Log object and pass your log 
    /// info here.
    public static func log(_ message: String) {
        
        let metadata: [String : Any] = [
            "deviceModel": "iPad 5",
            "userId": "17939101",
            "isTest": true
        ]
        
        let log = Log(message: message, level: .debug, metadata: metadata)
        
        Logger.instance.logger.log(log)
    }
}

extension Logger : SwiftBufferedLogDelegate {
    
    
    /// Send Logs
    /// Use your own method of uploading logs here.
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
    
    /// Logs Failed to Send
    /// This function is called when a batch of logs has failed to send the specified number of times.
    func didFailToSendLogs(_ logs: [Log]) {
        print("Logs failed to send after retrying: \(logs.map { $0.message + "\n" })")
    }
    
}
```
### Usage in app
```swift 
func exampleFunction() {
    Logger.log("exampleFunction called")
}
```
