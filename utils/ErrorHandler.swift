import Foundation
import SwiftUI

// MARK: - Error Types

enum AppError: LocalizedError {
    case audioProcessingFailed(String)
    case networkError(String)
    case fileSystemError(String)
    case aiProcessingError(String)
    case userCancelled
    case unauthorized
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .audioProcessingFailed(let details):
            return "Audio Processing Failed: \(details)"
        case .networkError(let details):
            return "Network Error: \(details)"
        case .fileSystemError(let details):
            return "File System Error: \(details)"
        case .aiProcessingError(let details):
            return "AI Processing Error: \(details)"
        case .userCancelled:
            return "Operation Cancelled"
        case .unauthorized:
            return "Unauthorized Access"
        case .unknown(let details):
            return "Unknown Error: \(details)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .audioProcessingFailed:
            return "Try reducing the audio file size or using a different format."
        case .networkError:
            return "Check your internet connection and try again."
        case .fileSystemError:
            return "Make sure you have enough storage space available."
        case .aiProcessingError:
            return "Try again with simpler parameters or contact support."
        case .userCancelled:
            return "Operation was cancelled by user."
        case .unauthorized:
            return "Please sign in again to continue."
        case .unknown:
            return "Try restarting the app or contact support if the problem persists."
        }
    }
}

// MARK: - Error Handler

class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showingError = false
    
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handle(_ error: Error) {
        DispatchQueue.main.async {
            if let appError = error as? AppError {
                self.currentError = appError
            } else {
                self.currentError = .unknown(error.localizedDescription)
            }
            self.showingError = true
        }
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.currentError = nil
            self.showingError = false
        }
    }
}

// MARK: - Error View Modifier

struct ErrorAlert: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: $errorHandler.showingError,
                actions: {
                    Button("OK") {
                        errorHandler.clearError()
                    }
                },
                message: {
                    if let error = errorHandler.currentError {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(error.errorDescription ?? "Unknown error")
                            if let recovery = error.recoverySuggestion {
                                Text(recovery)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            )
    }
}

extension View {
    func handleErrors(with errorHandler: ErrorHandler = .shared) -> some View {
        self.modifier(ErrorAlert(errorHandler: errorHandler))
    }
}

// MARK: - AI-Specific Error Types

enum AIError: LocalizedError {
    case modelLoadFailed(String)
    case inferenceTimeout(String)
    case lowConfidenceResult(String, Double)
    case unsupportedAudioFormat(String)
    case insufficientData(String)
    case processingOverload(String)
    
    var errorDescription: String? {
        switch self {
        case .modelLoadFailed(let details):
            return "AI Model Load Failed: \(details)"
        case .inferenceTimeout(let operation):
            return "AI Processing Timeout: \(operation)"
        case .lowConfidenceResult(let feature, let confidence):
            return "Low Confidence Result: \(feature) (\(Int(confidence * 100))%)"
        case .unsupportedAudioFormat(let format):
            return "Unsupported Audio Format: \(format)"
        case .insufficientData(let details):
            return "Insufficient Data: \(details)"
        case .processingOverload(let details):
            return "AI Processing Overload: \(details)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .modelLoadFailed:
            return "Try restarting the app or check for updates."
        case .inferenceTimeout:
            return "The audio might be too complex. Try with a shorter segment."
        case .lowConfidenceResult:
            return "The AI isn't quite sure about this one. Try with clearer audio."
        case .unsupportedAudioFormat:
            return "This audio format isn't supported. Try converting to MP3 or WAV."
        case .insufficientData:
            return "We need more data to make accurate predictions. Keep listening!"
        case .processingOverload:
            return "The AI is a bit overwhelmed. Try again in a moment."
        }
    }
    
    var recoveryOptions: [String] {
        switch self {
        case .modelLoadFailed:
            return ["Restart App", "Check for Updates", "Try Again"]
        case .inferenceTimeout:
            return ["Try Shorter Segment", "Reduce Quality", "Try Again"]
        case .lowConfidenceResult:
            return ["Try Again", "Skip Analysis", "Use Manual Mode"]
        case .unsupportedAudioFormat:
            return ["Convert Format", "Choose Different File"]
        case .insufficientData:
            return ["Continue in Learning Mode", "Use Basic Features"]
        case .processingOverload:
            return ["Retry", "Disable AI Features", "Try Later"]
        }
    }
}

// MARK: - Error View Modifiers

struct AIErrorAlert: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    let onRecoveryAction: ((String) -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(
                "AI Processing Error",
                isPresented: $errorHandler.showingError,
                actions: {
                    if let error = errorHandler.currentError as? AIError {
                        ForEach(error.recoveryOptions, id: \.self) { option in
                            Button(option) {
                                onRecoveryAction?(option)
                                errorHandler.clearError()
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        errorHandler.clearError()
                    }
                },
                message: {
                    if let error = errorHandler.currentError {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(error.localizedDescription)
                            if let recovery = (error as? LocalizedError)?.recoverySuggestion {
                                Text(recovery)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            )
    }
}

extension View {
    func handleAIErrors(
        with errorHandler: ErrorHandler = .shared,
        onRecoveryAction: ((String) -> Void)? = nil
    ) -> some View {
        self.modifier(AIErrorAlert(errorHandler: errorHandler, onRecoveryAction: onRecoveryAction))
    }
}
