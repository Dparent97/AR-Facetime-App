//
//  AppError.swift
//  Aria's Magic SharePlay App
//
//  Comprehensive error handling types
//

import Foundation

// MARK: - Error Types

enum AppError: LocalizedError {
    case arNotSupported
    case arSessionFailed(String)
    case arConfigurationFailed(String)
    case faceTrackingNotAvailable
    case faceTrackingFailed(String)
    case sharePlayActivationFailed(String)
    case sharePlayMessageFailed(String)
    case sharePlayNotAvailable
    case networkError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .arNotSupported:
            return "AR Not Available"
        case .arSessionFailed:
            return "AR Session Error"
        case .arConfigurationFailed:
            return "AR Configuration Failed"
        case .faceTrackingNotAvailable:
            return "Face Tracking Unavailable"
        case .faceTrackingFailed:
            return "Face Tracking Error"
        case .sharePlayActivationFailed:
            return "SharePlay Error"
        case .sharePlayMessageFailed:
            return "SharePlay Message Error"
        case .sharePlayNotAvailable:
            return "SharePlay Unavailable"
        case .networkError:
            return "Network Error"
        case .unknown:
            return "Unknown Error"
        }
    }

    var failureReason: String? {
        switch self {
        case .arNotSupported:
            return "This device doesn't support AR features. You'll be able to see characters but won't be able to place them in your space."
        case .arSessionFailed(let reason):
            return "The AR session encountered an error: \(reason)"
        case .arConfigurationFailed(let reason):
            return "Failed to configure AR: \(reason)"
        case .faceTrackingNotAvailable:
            return "Face tracking is not available on this device. You can still spawn and interact with characters."
        case .faceTrackingFailed(let reason):
            return "Face tracking error: \(reason)"
        case .sharePlayActivationFailed(let reason):
            return "Could not start SharePlay: \(reason)"
        case .sharePlayMessageFailed(let reason):
            return "Failed to send message to other participants: \(reason)"
        case .sharePlayNotAvailable:
            return "SharePlay is not available. Make sure you're in a FaceTime call."
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .unknown(let reason):
            return "An unexpected error occurred: \(reason)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .arNotSupported:
            return "You can still use the app, but AR features will be limited."
        case .arSessionFailed, .arConfigurationFailed:
            return "Try restarting the app. If the problem persists, check your device's AR capabilities in Settings."
        case .faceTrackingNotAvailable, .faceTrackingFailed:
            return "Continue using the app without face tracking features."
        case .sharePlayActivationFailed:
            return "Make sure you're in a FaceTime call and have granted necessary permissions."
        case .sharePlayMessageFailed:
            return "Check your network connection and try again."
        case .sharePlayNotAvailable:
            return "Start a FaceTime call first, then try SharePlay again."
        case .networkError:
            return "Check your internet connection and try again."
        case .unknown:
            return "Please try restarting the app."
        }
    }

    var severity: ErrorSeverity {
        switch self {
        case .arNotSupported, .faceTrackingNotAvailable:
            return .warning
        case .sharePlayNotAvailable, .sharePlayMessageFailed:
            return .info
        case .arSessionFailed, .arConfigurationFailed, .faceTrackingFailed, .sharePlayActivationFailed:
            return .error
        case .networkError, .unknown:
            return .error
        }
    }
}

enum ErrorSeverity {
    case info       // User can continue, minimal impact
    case warning    // Feature degradation, but app usable
    case error      // Significant issue, may impact core functionality
    case critical   // App cannot function properly
}

// MARK: - Error State

struct ErrorState: Identifiable {
    let id = UUID()
    let error: AppError
    let timestamp: Date
    var isDismissed: Bool = false

    init(error: AppError) {
        self.error = error
        self.timestamp = Date()
    }
}
