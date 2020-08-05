//
//  LogContainer.swift
//  SwiftBufferedLogging
//
//  Created by Brandon Baker on 8/5/20.
//

import UIKit


/// The method that send the logs back to
/// the main package class when they are
/// ready to be sent to the api
protocol LogContainerDelegate {
    func dispatchLogs(_ logs: [Log])
}

/// The log container
/// Handles holding logs until after logOptions.minBufferSize is reached and
/// before logOptions.maxBufferSize is reached, or logOptions.saveTime has passed
internal class LogContainer {
    
    private var delegate : LogContainerDelegate!
    private let logOptions: LogOptions
    private var bufferedLogs : [Log] = [] {
        didSet {
            checkMinAndMaxSize()
        }
    }
    
    /// Initializer
    /// - Parameters:
    ///   - delegate: Contains method for sending logs to the server
    ///   - logOptions: Contains options for how many logs to store and
    ///                 how long to hold them before sending them
    init(delegate: LogContainerDelegate, logOptions: LogOptions) {
        self.delegate = delegate
        self.logOptions = logOptions
    }
    
    /// Add Log
    /// Adds a log to the list of logs to send
    /// - Parameter log: Log item to add to the buffer
    func addLog(_ log: Log) {
        bufferedLogs.append(log)
    }
    
    /// Send Logs
    /// Called when the log buffer is full, or
    /// sufficient time has passed
    private func sendLogs() {
        delegate.dispatchLogs(bufferedLogs)
        bufferedLogs = []
    }
    
}

extension LogContainer {
    
    
    /// Will test the size of bufferedLogs against
    /// the specified min and max. Will send logs
    /// if the size limit has been reached
    private func checkMinAndMaxSize() {
        
        let currentLogCount = bufferedLogs.count
        
        guard currentLogCount >= logOptions.minBufferSize else {
            return
        }
        
        if currentLogCount >= logOptions.maxBufferSize {
            sendLogs()
        }
        
    }
    
    
}
