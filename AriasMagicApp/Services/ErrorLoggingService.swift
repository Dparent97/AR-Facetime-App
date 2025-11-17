//
//  ErrorLoggingService.swift
//  Aria's Magic SharePlay App
//
//  Centralized error logging and tracking
//

import Foundation
import os.log

class ErrorLoggingService {
    static let shared = ErrorLoggingService()

    private let logger = Logger(subsystem: "com.ariasmagic.app", category: "ErrorLogging")
    private var errorHistory: [ErrorState] = []
    private let maxHistorySize = 100

    private init() {}

    func logError(_ error: AppError, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let location = "\(fileName):\(line) - \(function)"

        // Log based on severity
        switch error.severity {
        case .info:
            logger.info("ℹ️ [\(location)] \(error.localizedDescription) - \(error.failureReason ?? "")")
        case .warning:
            logger.warning("⚠️ [\(location)] \(error.localizedDescription) - \(error.failureReason ?? "")")
        case .error:
            logger.error("❌ [\(location)] \(error.localizedDescription) - \(error.failureReason ?? "")")
        case .critical:
            logger.critical("🚨 [\(location)] \(error.localizedDescription) - \(error.failureReason ?? "")")
        }

        // Add to history
        let errorState = ErrorState(error: error)
        errorHistory.append(errorState)

        // Trim history if needed
        if errorHistory.count > maxHistorySize {
            errorHistory.removeFirst(errorHistory.count - maxHistorySize)
        }

        // In production, you could send errors to a crash reporting service
        #if DEBUG
        print("🐛 DEBUG: \(error.localizedDescription) at \(location)")
        #endif
    }

    func getErrorHistory() -> [ErrorState] {
        return errorHistory
    }

    func clearHistory() {
        errorHistory.removeAll()
    }

    // Convenience method for logging Swift errors
    func logSwiftError(_ error: Error, context: String, file: String = #file, function: String = #function, line: Int = #line) {
        let appError = AppError.unknown("\(context): \(error.localizedDescription)")
        logError(appError, file: file, function: function, line: line)
    }
}
