import XCTest
@testable import AI_Mixtapes

class HybridRecsManagerTests: XCTestCase {
    var mockLLMService: MockLLMService!
    var hybridRecsManager: HybridRecsManager!
    
    override func setUp() {
        super.setUp()
        mockLLMService = MockLLMService()
        hybridRecsManager = HybridRecsManager(llmService: mockLLMService)
    }
    
    override func tearDown() {
        mockLLMService = nil
        hybridRecsManager = nil
        super.tearDown()
    }
    
    func testInitWithDefaultWeights() {
        // Initial weights should be the defaults
        let weights = hybridRecsManager.getCurrentWeights()
        
        XCTAssertEqual(weights["recency"], 0.5)
        XCTAssertEqual(weights["similarity"], 0.3)
        XCTAssertEqual(weights["popularity"], 0.2)
    }
    
    func testParseValidWeightsFromLLM() async {
        // Set up mock LLM response
        let validJSON = "{\"recency\": 0.6, \"similarity\": 0.3, \"popularity\": 0.1}"
        mockLLMService.mockResponse = validJSON
        
        // Create new manager to trigger weight fetching
        let manager = HybridRecsManager(llmService: mockLLMService)
        
        // Wait for async operation to complete
        await waitForAsync()
        
        // Verify weights were updated
        let weights = manager.getCurrentWeights()
        XCTAssertEqual(weights["recency"], 0.6)
        XCTAssertEqual(weights["similarity"], 0.3)
        XCTAssertEqual(weights["popularity"], 0.1)
    }
    
    func testInvalidJSONFallback() async {
        // Set up invalid JSON response
        mockLLMService.mockResponse = "This is not valid JSON"
        
        // Create new manager
        let manager = HybridRecsManager(llmService: mockLLMService)
        
        // Wait for async operation
        await waitForAsync()
        
        // Verify default weights were used
        let weights = manager.getCurrentWeights()
        XCTAssertEqual(weights["recency"], 0.5)
        XCTAssertEqual(weights["similarity"], 0.3)
        XCTAssertEqual(weights["popularity"], 0.2)
    }
    
    func testMissingKeysFallback() async {
        // JSON missing a required key
        mockLLMService.mockResponse = "{\"recency\": 0.7, \"similarity\": 0.3}"
        
        // Create new manager
        let manager = HybridRecsManager(llmService: mockLLMService)
        
        // Wait for async operation
        await waitForAsync()
        
        // Verify default weights were used
        let weights = manager.getCurrentWeights()
        XCTAssertEqual(weights["recency"], 0.5)
        XCTAssertEqual(weights["similarity"], 0.3)
        XCTAssertEqual(weights["popularity"], 0.2)
    }
    
    func testInvalidSumFallback() async {
        // Weights that don't sum to 1.0
        mockLLMService.mockResponse = "{\"recency\": 0.9, \"similarity\": 0.8, \"popularity\": 0.5}"
        
        // Create new manager
        let manager = HybridRecsManager(llmService: mockLLMService)
        
        // Wait for async operation
        await waitForAsync()
        
        // Verify default weights were used
        let weights = manager.getCurrentWeights()
        XCTAssertEqual(weights["recency"], 0.5)
        XCTAssertEqual(weights["similarity"], 0.3)
        XCTAssertEqual(weights["popularity"], 0.2)
    }
    
    // Helper to wait for async operations
    private func waitForAsync() async {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
}

class MockLLMService: LLMService {
    var mockResponse: String = "{}"
    
    func complete(prompt: String) async throws -> String {
        return mockResponse
    }
}