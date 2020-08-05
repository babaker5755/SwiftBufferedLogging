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
    func sendSingleLog(_ log: Log, error: (() -> Void))
    func sendBatchLogs(_ logs: [Log], error: (() -> Void))
}

/// Package Class
public class SwiftBufferedLogging {
    
    private let logOptions: LogOptions
    private var logContainer: LogContainer!
    private let delegate: SwiftBufferedLogDelegate
    
    /// Main package initializer
    /// A conforming class in the user's project will
    /// handle dispatching single and batch logs
    /// - Parameters:
    ///   - delegate: Should contain methods for handling sending logs a logging api
    ///   - logOptions: Contains options for how many logs to store and how long to hold them before sending them
    init(delegate: SwiftBufferedLogDelegate, logOptions: LogOptions = LogOptions()) {
        self.delegate = delegate
        self.logOptions = logOptions
        self.logContainer = LogContainer(delegate: self, logOptions: logOptions)
    }
    
    /// Handle log
    /// - Parameters:
    ///   - log: the log to be handled
    ///   - sendInstantly: Set to true to skip holding the log in the buffer
    private func handleLog(_ log: Log,_ sendInstantly: Bool) {
        
        if sendInstantly {
            delegate.sendSingleLog(log) {
                // Handle Retries
            }
            return
        }
        
        logContainer.addLog(log) 
    }
    
}

// MARK: User Methods
extension SwiftBufferedLogging {
    
    /// Log
    /// Takes input and creates a log that will be managed throughout the framework
    /// - Parameters:
    ///   - message: Message to attach to the log
    ///   - metadata: Any metadata that should be sent with the log
    ///   - sendInstantly: Set to true to skip holding the log in the buffer
    public func log(_ message: String, metadata: [String: Any] = [:], logLevel: LogLevel = .debug, tags: [String], sendInstantly: Bool = false) {
        
        let log = Log(message: message, level: logLevel, tags: tags, metadata: metadata)
        
        handleLog(log, sendInstantly)
        
    }
    
    /// Log
    /// Takes the log as input and handles it
    /// - Parameters:
    ///   - log: the log object that will be handled
    ///   - sendInstantly: Set to true to skip
    ///                    holding the log in the buffer
    public func log(_ log: Log, sendInstantly: Bool = false) {
        handleLog(log, sendInstantly)
    }
    
}


// MARK: Log Container Delegate
extension SwiftBufferedLogging : LogContainerDelegate {
    
    /// Dispatch Logs
    /// Called when the log container is ready to send logs
    /// - Parameter logs: Logs received from the log container
    func dispatchLogs(_ logs: [Log]) {
        delegate.sendBatchLogs(logs) {
            // Handle Retries
        }
    }
    
}
