//
//  SwiftBufferedLogging.swift
//  SwiftBufferedLogging
//
//  Created by Brandon Baker on 8/5/20.
//
import UIKit

// MARK: User-given methods
/// Handles logs when they are ready to be sent,
/// calling error() in the delegate function will trigger
/// the retry handler for those logs
public protocol SwiftBufferedLogDelegate {
    func sendLogs(_ logs: [Log], completion: @escaping ((Bool) -> Void))
    func didFailToSendLogs(_ logs: [Log])
}


public class SwiftBufferedLogging {
    
    private let logOptions: LogOptions
    private var logContainer: LogContainer!
    private let delegate: SwiftBufferedLogDelegate
    
    /// - Parameters:
    ///   - delegate: Contains methods for handling sending logs a logging api
    ///   - logOptions: Contains options for how many logs to store and how long to hold them before sending them
    public init(delegate: SwiftBufferedLogDelegate, logOptions: LogOptions = LogOptions()) {
        self.delegate = delegate
        self.logOptions = logOptions
        self.logContainer = LogContainer(delegate: self, logOptions: logOptions)
    }
    
    /// - Parameters:
    ///   - log: the log to be handled
    ///   - sendInstantly: Set to true to skip holding the log in the buffer
    private func handleLog(_ log: Log,_ sendInstantly: Bool) {
        
        if sendInstantly {
            let batch = Batch([log], delegate: self, logOptions: logOptions)
            dispatchLogs(batch)
            return
        }
        
        logContainer.addLog(log) 
    }
    
}

// MARK: User Methods
extension SwiftBufferedLogging {
    
    
    /// Creates a log that will be managed throughout the framework
    /// - Parameters:
    ///   - message: Message to attach to the log
    ///   - metadata: Any metadata that should be sent with the log
    ///   - sendInstantly: Set to true to skip holding the log in the buffer
    public func log(_ message: String, metadata: [String: Any] = [:], logLevel: LogLevel = .debug, sendInstantly: Bool = false) {
        let log = Log(message: message, level: logLevel, metadata: metadata)
        handleLog(log, sendInstantly)
    }
    
    /// - Parameters:
    ///   - log: the log object that will be handled
    ///   - sendInstantly: Skip holding the log in the buffer - default: false
    public func log(_ log: Log, sendInstantly: Bool = false) {
        handleLog(log, sendInstantly)
    }
    
}

// MARK: LogDispatchDelegate
extension SwiftBufferedLogging : LogDispatchDelegate {
    
    /// - Parameter batch: the failed batch of logs
    func failedLogs(_ batch: Batch) {
        delegate.didFailToSendLogs(batch.logs)
    }
    
    /// Called when the log container is ready to send logs
    /// - Parameter logs: Logs received from the log container
    func dispatchLogs(_ batch: Batch) {
        
        delegate.sendLogs(batch.logs) { success in
            
            guard success else {
                self.handleError(batch)
                return
            }
            
            batch.remove()
        }
    }
    
    /// - Parameter batch: the batch to be retried
    func handleError(_ batch: Batch) {
        batch.add()
        batch.retry()
    }
    
}
