//
//  Log.swift
//  SolSol
//
//  Created by NUNU:D on 6/5/25.
//

import Foundation
import OSLog

public class Log {
    
    public enum LogLevel {
        case debug
        case info
        case warning
        case error
        case custom(String)
        
        var level: OSLogType {
            switch self {
            case .debug:            return .debug
            case .info:             return .info
            case .warning:          return .error
            case .error:            return .fault
            case .custom:           return .debug
            }
        }
        
        var category: String {
            switch self {
            case .debug:                        return "DEBUG"
            case .info:                         return "INFO"
            case .warning:                      return "WARNING"
            case .error:                        return "ERRROR"
            case .custom(let category):         return category.uppercased()
            }
        }
        
        var seperator: String {
            switch self {
            case .debug:                        return "✅"
            case .info:                         return "ℹ️"
            case .warning:                      return "⚠️"
            case .error:                        return "❌"
            case .custom:                       return "☑️"
            }
        }
        
    }
    
    public var subsystem: String {
        return Bundle.main.bundleIdentifier ?? "SolSol"
    }
    
    public func message(_ message: String, level: LogLevel) {
        let log = OSLog(subsystem: subsystem, category: level.category)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.timeZone = .autoupdatingCurrent
        let currentDate = formatter.string(from: Date())
        let logMessage = """
        [\(level.seperator) \(level.category)] Date: \(currentDate)
        \(message)
        """
        os_log("%{public}@", log: log, type: level.level, logMessage)
    }
    
    static func d(_ message: String) {
        let log = Log()
        log.message(message, level: .debug)
    }
    
    static func i(_ message: String) {
        let log = Log()
        log.message(message, level: .info)
    }
    
    static func w(_ message: String) {
        let log = Log()
        log.message(message, level: .warning)
    }
    
    static func e(_ message: String) {
        let log = Log()
        log.message(message, level: .error)
    }
    
    static func custom(_ message: String, category: String) {
        let log = Log()
        log.message(message, level: .custom(category))
    }
}
