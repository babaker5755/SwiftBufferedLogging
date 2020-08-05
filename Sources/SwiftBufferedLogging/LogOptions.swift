//
//  LogOptions.swift
//  SwiftBufferedLogging
//
//  Created by Brandon Baker on 8/5/20.
//

import UIKit

class LogOptions {
    
    let saveTime: Double
    let maxBufferSize: Int
    let minBufferSize : Int
    
    /// Initializer
    /// - Parameters:
    ///   - saveTime: Number of seconds the buffer should hold logs before sending
    ///   - maxBufferSize: Maximum number of logs the buffer can contain before sending
    ///   - minBufferSize: Minimum number of logs the buffer should contain before sending
    init(saveTime: Double = 5, maxBufferSize: Int = 10, minBufferSize : Int = 0) {
        
        guard minBufferSize <= maxBufferSize else {
            fatalError("LogOptions Error: maxBufferSize(\(maxBufferSize) must be lower than minBufferSize(\(minBufferSize))")
        }
        
        guard saveTime > 0 else {
            fatalError("LogOptions Error: saveTime must be greater than 0")
        }
        
        self.saveTime = saveTime
        self.maxBufferSize = maxBufferSize
        self.minBufferSize = minBufferSize
    }
}
