//
//  LogOptions.swift
//  SwiftBufferedLogging
//
//  Created by Brandon Baker on 8/5/20.
//

import UIKit

public class LogOptions {
    
    let saveTime: Double
    let maxBufferSize: Int
    let minBufferSize : Int
    let maxRetries: Int
    
    /// Initializer
    /// - Parameters:
    ///   - saveTime: Number of seconds the buffer should hold logs before sending
    ///   - maxBufferSize: Maximum number of logs the buffer can contain before sending
    ///   - minBufferSize: Minimum number of logs the buffer should contain before sending
    public init(saveTime: Double = 5, maxBufferSize: Int = 10, minBufferSize : Int = 0, maxRetries: Int = 3) {
        
        guard [Int(saveTime), maxBufferSize, minBufferSize, maxRetries].filter({ $0 < 0 }).count == 0 else {
            fatalError("LogOptions Error: can not use negative number.")
        }
        
        guard minBufferSize <= maxBufferSize else {
            fatalError("LogOptions Error: maxBufferSize(\(maxBufferSize) must be lower than minBufferSize(\(minBufferSize))")
        }
        
        guard saveTime > 0 else {
            fatalError("LogOptions Error: saveTime must be greater than 0")
        }
        
        self.saveTime = saveTime
        self.maxBufferSize = maxBufferSize
        self.minBufferSize = minBufferSize
        self.maxRetries = maxRetries
    }
}
