import Foundation
import Combine

enum AnthropicError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case apiError(String)
}

struct AnthropicMessage: Codable {
    let role: String
    let content: String
}

struct AnthropicRequest: Codable {
    let model: String
    let maxTokens: Int
    let tools: [AnthropicTool]
    let messages: [AnthropicMessage]
    
    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case tools
        case messages
    }
}

struct AnthropicTool: Codable {
    let name: String
    let description: String
    let inputSchema: AnthropicToolSchema
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case inputSchema = "input_schema"
    }
}

struct AnthropicToolSchema: Codable {
    let type: String
    let properties: [String: AnthropicToolProperty]
    let required: [String]
}

struct AnthropicToolProperty: Codable {
    let type: String
    let description: String
}

class AnthropicService {
    static let shared = AnthropicService()
    private let session = URLSession.shared
    
    private init() {}
    
    func sendMessage(content: String, tools: [AnthropicTool] = []) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: "\(APIConfig.anthropicBaseURL)/messages") else {
            return Fail(error: AnthropicError.invalidURL).eraseToAnyPublisher()
        }
        
        let message = AnthropicMessage(role: "user", content: content)
        let request = AnthropicRequest(
            model: "claude-3-7-sonnet-20250219",
            maxTokens: 1024,
            tools: tools,
            messages: [message]
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        APIConfig.defaultHeaders.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .mapError { AnthropicError.requestFailed($0) }
            .eraseToAnyPublisher()
    }
    
    func processWeatherRequest(location: String) -> AnyPublisher<String, Error> {
        let weatherTool = AnthropicTool(
            name: "get_weather",
            description: "Get the current weather in a given location",
            inputSchema: AnthropicToolSchema(
                type: "object",
                properties: [
                    "location": AnthropicToolProperty(
                        type: "string",
                        description: "The city and state, e.g. San Francisco, CA"
                    )
                ],
                required: ["location"]
            )
        )
        
        return sendMessage(
            content: "Tell me the weather in \(location).",
            tools: [weatherTool]
        )
        .map { data -> String in
            if let response = try? JSONDecoder().decode([String: Any].self, from: data) as? [String: String] {
                return response["content"] ?? "Unable to get weather information"
            }
            return "Unable to process weather response"
        }
        .eraseToAnyPublisher()
    }
}
