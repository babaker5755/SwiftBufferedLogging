//
//  Log.swift
//  SwiftBufferedLogging
//
//  Created by Brandon Baker on 8/5/20.
//

import UIKit



/// The basic log model for SwiftBufferedLogging
public class Log {
    
    let message : String
    let metadata : [String: Any]
    let level : LogLevel
    let tags : [String]
    
    
    /// Initializer
    /// - Parameters:
    ///   - message: The 'title' of the log
    ///   - level: A level description of the log
    ///   - tags: Any extra identifying information. Not used by SwiftBufferedLogging.
    ///   - metadata: Log metadata
    init(message: String, level: LogLevel = .debug, tags: [String] = [], metadata: [String: Any] = [:]) {
        self.message = message
        self.metadata = metadata
        self.level = level
        self.tags = tags
    }
}

public enum LogLevel : String, Codable {
    case debug = "DEBUG"
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"
    case fatal = "FATAL"
}
