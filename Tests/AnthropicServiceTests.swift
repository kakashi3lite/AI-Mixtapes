import XCTest
@testable import AI_Mixtapes

class AnthropicServiceTests: XCTestCase {
    var service: AnthropicService!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        service = AnthropicService.shared
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // Test message sending format
    func testSendMessageFormat() {
        let expectation = XCTestExpectation(description: "Send message")
        let content = "Hello, how's the weather?"
        
        // Test basic message send
        service.sendMessage(content: content)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Message sending failed with error: \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { data in
                // Verify response format
                XCTAssertNotNil(data)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test weather query functionality
    func testWeatherQuery() {
        let expectation = XCTestExpectation(description: "Weather query")
        let location = "San Francisco, CA"
        
        service.processWeatherRequest(location: location)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Weather query failed with error: \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { response in
                XCTAssertNotNil(response)
                XCTAssertTrue(response.contains(location))
            })
            .store(in: &cancellables)
            
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test error handling
    func testErrorHandling() {
        let expectation = XCTestExpectation(description: "Error test")
        let invalidContent = ""
        
        service.sendMessage(content: invalidContent)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    if case AnthropicError.invalidRequest = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected invalid request error")
                    }
                case .finished:
                    XCTFail("Expected error for empty content")
                }
            }, receiveValue: { _ in
                XCTFail("Should not receive value for invalid request")
            })
            .store(in: &cancellables)
            
        wait(for: [expectation], timeout: 5.0)
    }
    
    // Test tool schema validation
    func testToolSchemaValidation() {
        let weatherTool = AnthropicTool(
            name: "get_weather",
            description: "Get the weather",
            inputSchema: AnthropicToolSchema(
                type: "object",
                properties: [
                    "location": AnthropicToolProperty(
                        type: "string",
                        description: "Location for weather"
                    )
                ],
                required: ["location"]
            )
        )
        
        // Verify tool schema structure
        XCTAssertEqual(weatherTool.name, "get_weather")
        XCTAssertEqual(weatherTool.inputSchema.type, "object")
        XCTAssertEqual(weatherTool.inputSchema.required, ["location"])
    }
    
    // Test API configuration
    func testAPIConfiguration() {
        let urlRequest = try? service.createRequest(for: "test")
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertNotNil(urlRequest?.allHTTPHeaderFields?["x-api-key"])
    }
    
    private var cancellables = Set<AnyCancellable>()
}
