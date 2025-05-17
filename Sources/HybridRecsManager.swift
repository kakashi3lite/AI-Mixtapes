import Foundation

class HybridRecsManager {
    private let llmService: LLMService
    private var weights: [String: Float] = [
        "recency": 0.5,
        "similarity": 0.3,
        "popularity": 0.2
    ]
    
    init(llmService: LLMService) {
        self.llmService = llmService
        fetchOptimalWeights()
    }
    
    private func fetchOptimalWeights() {
        // Async operation to avoid blocking init
        Task {
            do {
                let userHistory = getUserListeningHistory()
                let prompt = "Given user listening history: \(userHistory), suggest optimal weights for recommendation algorithm with keys 'recency', 'similarity', and 'popularity'. Values should sum to 1.0. Return JSON format."
                
                let response = try await llmService.complete(prompt: prompt)
                if let parsedWeights = parseWeightsFromLLM(response) {
                    self.weights = parsedWeights
                }
            } catch {
                print("Using default weights due to LLM error: \(error)")
            }
        }
    }
    
    private func parseWeightsFromLLM(_ response: String) -> [String: Float]? {
        guard let data = response.data(using: .utf8) else { return nil }
        do {
            let parsedWeights = try JSONDecoder().decode([String: Float].self, from: data)
            
            // Validate weights
            let requiredKeys = ["recency", "similarity", "popularity"]
            let hasAllKeys = requiredKeys.allSatisfy { parsedWeights.keys.contains($0) }
            
            // Ensure weights sum to approximately 1.0
            let sum = parsedWeights.values.reduce(0, +)
            let isValidSum = abs(sum - 1.0) < 0.01
            
            if hasAllKeys && isValidSum {
                return parsedWeights
            } else {
                print("Invalid weights from LLM: missing keys or sum != 1.0")
                return nil
            }
        } catch {
            print("Failed to parse LLM weights: \(error)")
            return nil
        }
    }
    
    private func getUserListeningHistory() -> String {
        // In a real app, fetch actual user history
        return "[{\"artist\":\"Taylor Swift\",\"plays\":23,\"lastPlayed\":\"2023-09-10\"}," + 
               "{\"artist\":\"The Weeknd\",\"plays\":15,\"lastPlayed\":\"2023-09-15\"}," + 
               "{\"artist\":\"Drake\",\"plays\":8,\"lastPlayed\":\"2023-08-25\"}]"
    }
    
    func getRecommendations(for item: String, count: Int = 10) -> [String] {
        // Example recommendation logic using weights
        // In a real app, this would use the weights with actual recommendation algorithms
        print("Generating recommendations using weights: \(weights)")
        
        // Mock recommendations
        return ["Recommendation 1", "Recommendation 2", "Recommendation 3"]
    }
    
    // For testing
    func getCurrentWeights() -> [String: Float] {
        return weights
    }
}