import Foundation
import MediaPlayer

/// Music service error types
/// Used for unified error handling and user feedback
enum MusicError: LocalizedError {
    // MARK: - Error Cases
    
    /// Unauthorized access to music library
    case notAuthorized
    /// Queue synchronization failed
    case queueSyncFailed
    /// Playback failed
    case playbackFailed
    /// Network connection error
    case networkError
    /// Unknown error
    case unknown(Error)
    
    // MARK: - LocalizedError
    
    /// Error description (user-visible)
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Music Library Access Required"
        case .queueSyncFailed:
            return "Failed to Sync Queue"
        case .playbackFailed:
            return "Playback Error"
        case .networkError:
            return "Network Connection Error"
        case .unknown(let error):
            return "Unexpected Error: \(error.localizedDescription)"
        }
    }
    
    /// Failure reason (detailed explanation)
    var failureReason: String? {
        switch self {
        case .notAuthorized:
            return "QueueMaster needs access to your Apple Music library to manage queues."
        case .queueSyncFailed:
            return "The queue could not be synchronized with Apple Music. This may be due to system restrictions."
        case .playbackFailed:
            return "The selected song could not be played. It may be unavailable or removed."
        case .networkError:
            return "A network connection is required for this operation."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    /// Recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .notAuthorized:
            return "Please grant music library access in Settings > Privacy > Media Library."
        case .queueSyncFailed:
            return "Try restarting the app or check if Apple Music is available."
        case .playbackFailed:
            return "Check your internet connection or try a different song."
        case .networkError:
            return "Please check your network connection and try again."
        case .unknown:
            return "Please restart the app and try again."
        }
    }
    
    /// Whether the error is recoverable
    var isRecoverable: Bool {
        switch self {
        case .notAuthorized, .queueSyncFailed, .playbackFailed:
            return true
        case .networkError, .unknown:
            return false
        }
    }
}

// MARK: - Error Extension

extension MusicError {
    /// Create MusicError from system error
    static func from(_ error: Error) -> MusicError {
        let nsError = error as NSError
        
        // Check if it's a music player related error
        if nsError.domain.contains("music") || nsError.domain.contains("Music") {
            return .playbackFailed
        }
        
        // Check error code for common playback errors
        if nsError.code >= 0 && nsError.code < 1000 {
            return .playbackFailed
        }
        
        return .unknown(error)
    }
    
    /// Create MusicError from HTTP status code
    static func fromHTTPStatus(_ statusCode: Int) -> MusicError {
        switch statusCode {
        case 401, 403:
            return .notAuthorized
        case 408, 503:
            return .networkError
        default:
            return .unknown(NSError(domain: "HTTP", code: statusCode))
        }
    }
}

// MARK: - Equatable

extension MusicError: Equatable {
    static func == (lhs: MusicError, rhs: MusicError) -> Bool {
        switch (lhs, rhs) {
        case (.notAuthorized, .notAuthorized),
             (.queueSyncFailed, .queueSyncFailed),
             (.playbackFailed, .playbackFailed),
             (.networkError, .networkError):
            return true
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
