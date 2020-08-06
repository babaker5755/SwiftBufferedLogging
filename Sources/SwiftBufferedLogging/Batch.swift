//
//  Batch.swift
//  SwiftBufferedLogging
//
//  Created by Brandon Baker on 8/5/20.
//

import UIKit

class Batch {
    
    static var batches : [Batch] = []
    
    let id : String
    let logs : [Log]
    
    private let logOptions : LogOptions
    private var timeIncrementInSeconds : Double = 0.1
    private let delegate : LogDispatchDelegate
    private var retries = 0 {
        didSet {
            timeIncrementInSeconds = Double(retries * retries) * timeIncrementInSeconds
            print("timeIncrementInMilliseconds:\(timeIncrementInSeconds)")
        }
    }
    
    /// Initializer
    /// - Parameters:
    ///   - logs: buffered logs to send
    ///   - delegate: contains function for sending logs
    ///   - logOptions: contains log options
    init(_ logs: [Log], delegate: LogDispatchDelegate, logOptions: LogOptions) {
        self.id = UUID().uuidString
        self.logs = logs
        self.retries = 0
        self.logOptions = logOptions
        self.delegate = delegate
    }
    
    /// Adds batch to the static array
    func add() {
        guard !Batch.batches.contains(where: { $0.id == id }) else { return }
        Batch.batches.append(self)
    }
    
    /// Removes batch from the static array
    func remove() {
        Batch.batches.removeAll(where: {$0.id == id})
    }
    
    /// Retry handler
    /// Will ensure the batch is not retried more than logOptions.maxRetries,
    /// increments the retry count, and sets a timer to send logs after the
    /// timeIncrementInSeconds has passed
    func retry() {
        
        guard retries <= logOptions.maxRetries else {
            print("retry limit reached")
            delegate.failedLogs(self)
            return
        }
        
        print("retrying\(id) - \(retries) time")
        
        retries += 1
        
        guard let timeInterval = TimeInterval(exactly: timeIncrementInSeconds) else { return }
        
        print("retrying in \(timeInterval)")
        
        guard #available(iOS 10.0, *) else {
            fatalError("SwiftBufferedTimer Error : Must be using iOS 10.0 or greater.")
        }
        
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.delegate.dispatchLogs(self)
        }
        
    }
}
