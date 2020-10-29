//
//  Log.swift
//  SwiftBufferedLogging
//
//  Created by Brandon Baker on 8/5/20.
//

import UIKit

open class Log {
    
    public let message : String
    public let metadata : [String: Any]
    public let level : LogLevel
    
    public init(message: String, level: LogLevel = .debug, metadata: [String: Any] = [:]) {
        self.message = message
        self.metadata = metadata
        self.level = level
    }
    
}

public enum LogLevel : String, Codable {
    case debug = "DEBUG"
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"
    case fatal = "FATAL"
}
