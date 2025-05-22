import Foundation

enum APIConfig {
    static let anthropicAPIKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    static let anthropicBaseURL = "https://api.anthropic.com/v1"
    static let anthropicVersion = "2023-06-01"
    static let anthropicBeta = "token-efficient-tools-2025-02-19"
    
    static let defaultHeaders: [String: String] = [
        "content-type": "application/json",
        "x-api-key": anthropicAPIKey,
        "anthropic-version": anthropicVersion,
        "anthropic-beta": anthropicBeta
    ]
}
