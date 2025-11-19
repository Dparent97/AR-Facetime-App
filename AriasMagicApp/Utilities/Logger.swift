//
//  Logger.swift
//  Aria's Magic SharePlay App
//
//  Structured logging system for debugging and error tracking
//

import Foundation
import os.log

/// Log levels for filtering and prioritization
enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4

    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .critical: return .fault
        }
    }

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Log categories for filtering
enum LogCategory: String {
    case general = "General"
    case core = "Core"
    case ui = "UI"
    case ar = "AR"
    case sharePlay = "SharePlay"
    case audio = "Audio"
    case faceTracking = "FaceTracking"
    case performance = "Performance"
    case network = "Network"
}

/// Centralized logging system with filtering, formatting, and export capabilities
class Logger {
    // MARK: - Singleton

    static let shared = Logger()

    // MARK: - Properties

    /// Minimum log level to display (logs below this are ignored)
    var minimumLogLevel: LogLevel = .info

    /// Whether to use emoji in log messages
    var useEmoji = true

    /// Whether to include timestamps
    var includeTimestamp = true

    /// Whether to include category in log messages
    var includeCategory = true

    /// Maximum number of log entries to keep in memory
    var maxLogEntries = 1000

    /// In-memory log storage for export
    private var logEntries: [LogEntry] = []

    /// Lock for thread-safe access to log entries
    private let logLock = NSLock()

    /// OSLog instances for each category
    private var osLogs: [LogCategory: OSLog] = [:]

    // MARK: - Initialization

    private init() {
        // Create OSLog instances for each category
        for category in LogCategory.allCases {
            osLogs[category] = OSLog(
                subsystem: "com.ariasmagic.app",
                category: category.rawValue
            )
        }
    }

    // MARK: - Logging Methods

    /// Log a message
    ///
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: Log level (default: .info)
    ///   - category: Log category (default: .general)
    ///   - file: Source file (auto-filled)
    ///   - function: Source function (auto-filled)
    ///   - line: Source line (auto-filled)
    func log(
        _ message: String,
        level: LogLevel = .info,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        // Filter by minimum log level
        guard level >= minimumLogLevel else { return }

        // Create log entry
        let entry = LogEntry(
            timestamp: Date(),
            level: level,
            category: category,
            message: message,
            file: file,
            function: function,
            line: line
        )

        // Store in memory
        storeLogEntry(entry)

        // Format and print
        let formattedMessage = formatLogMessage(entry)
        print(formattedMessage)

        // Send to OSLog
        if let osLog = osLogs[category] {
            os_log("%{public}@", log: osLog, type: level.osLogType, message)
        }
    }

    /// Log an error with context
    ///
    /// - Parameters:
    ///   - error: The error to log
    ///   - context: Additional context about where/why the error occurred
    ///   - category: Log category (default: .general)
    func logError(
        _ error: Error,
        context: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let message = "Error in \(context): \(error.localizedDescription)"
        log(
            message,
            level: .error,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }

    /// Convenience method for debug logs
    func debug(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }

    /// Convenience method for info logs
    func info(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }

    /// Convenience method for warning logs
    func warning(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }

    /// Convenience method for error logs
    func error(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }

    /// Convenience method for critical logs
    func critical(
        _ message: String,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .critical, category: category, file: file, function: function, line: line)
    }

    // MARK: - Log Management

    private func storeLogEntry(_ entry: LogEntry) {
        logLock.lock()
        defer { logLock.unlock() }

        logEntries.append(entry)

        // Trim if exceeding max
        if logEntries.count > maxLogEntries {
            logEntries.removeFirst(logEntries.count - maxLogEntries)
        }
    }

    /// Export all logs as formatted string
    func exportLogs() -> String {
        logLock.lock()
        defer { logLock.unlock() }

        var output = "=== Aria's Magic App Logs ===\n"
        output += "Exported: \(Date())\n"
        output += "Total Entries: \(logEntries.count)\n"
        output += "================================\n\n"

        for entry in logEntries {
            output += formatLogMessage(entry) + "\n"
        }

        return output
    }

    /// Clear all stored logs
    func clearLogs() {
        logLock.lock()
        defer { logLock.unlock() }

        logEntries.removeAll()
    }

    /// Get logs filtered by criteria
    func getLogs(
        level: LogLevel? = nil,
        category: LogCategory? = nil,
        since: Date? = nil
    ) -> [LogEntry] {
        logLock.lock()
        defer { logLock.unlock() }

        return logEntries.filter { entry in
            if let level = level, entry.level != level {
                return false
            }
            if let category = category, entry.category != category {
                return false
            }
            if let since = since, entry.timestamp < since {
                return false
            }
            return true
        }
    }

    // MARK: - Formatting

    private func formatLogMessage(_ entry: LogEntry) -> String {
        var parts: [String] = []

        // Timestamp
        if includeTimestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            parts.append(formatter.string(from: entry.timestamp))
        }

        // Level with emoji
        if useEmoji {
            parts.append("\(entry.level.emoji) [\(entry.level)]")
        } else {
            parts.append("[\(entry.level)]")
        }

        // Category
        if includeCategory {
            parts.append("[\(entry.category.rawValue)]")
        }

        // Message
        parts.append(entry.message)

        // Source location (only for debug builds)
        #if DEBUG
        if entry.level >= .warning {
            let fileName = (entry.file as NSString).lastPathComponent
            parts.append("(\(fileName):\(entry.line))")
        }
        #endif

        return parts.joined(separator: " ")
    }
}

// MARK: - Log Entry

/// Structure representing a single log entry
struct LogEntry {
    let timestamp: Date
    let level: LogLevel
    let category: LogCategory
    let message: String
    let file: String
    let function: String
    let line: Int
}

// MARK: - Extensions

extension LogCategory: CaseIterable {}
