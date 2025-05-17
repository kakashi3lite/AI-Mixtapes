import XCTest
@testable import RecommendationEngine

class VectorStoreTests: XCTestCase {
    var vectorStore: VectorStore!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        vectorStore = VectorStore(cachePath: tempDirectory)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        vectorStore = nil
        super.tearDown()
    }
    
    func testStoreAndRetrieve() throws {
        // Test data
        let vector: [Float] = [0.1, 0.2, 0.3, 0.4, 0.5]
        let key = "test-vector"
        
        // Store vector
        try vectorStore.store(vector: vector, forKey: key)
        
        // Check existence
        XCTAssertTrue(vectorStore.exists(forKey: key))
        
        // Retrieve vector
        let retrievedVector = try vectorStore.retrieve(forKey: key)
        
        // Verify
        XCTAssertEqual(retrievedVector.count, vector.count)
        for i in 0..<vector.count {
            XCTAssertEqual(retrievedVector[i], vector[i], accuracy: 0.0001)
        }
    }
    
    func testDelete() throws {
        // Test data
        let vector: [Float] = [0.1, 0.2, 0.3]
        let key = "delete-test"
        
        // Store vector
        try vectorStore.store(vector: vector, forKey: key)
        XCTAssertTrue(vectorStore.exists(forKey: key))
        
        // Delete vector
        try vectorStore.delete(forKey: key)
        
        // Verify deletion
        XCTAssertFalse(vectorStore.exists(forKey: key))
        
        // Verify retrieval throws
        XCTAssertThrowsError(try vectorStore.retrieve(forKey: key))
    }
    
    func testGetAllKeys() throws {
        // Store multiple vectors
        try vectorStore.store(vector: [0.1, 0.2], forKey: "key1")
        try vectorStore.store(vector: [0.3, 0.4], forKey: "key2")
        try vectorStore.store(vector: [0.5, 0.6], forKey: "key3")
        
        // Get all keys
        let keys = vectorStore.getAllKeys()
        
        // Verify
        XCTAssertEqual(keys.count, 3)
        XCTAssertTrue(keys.contains("key1"))
        XCTAssertTrue(keys.contains("key2"))
        XCTAssertTrue(keys.contains("key3"))
    }
    
    func testClear() throws {
        // Store multiple vectors
        try vectorStore.store(vector: [0.1, 0.2], forKey: "clear-test-1")
        try vectorStore.store(vector: [0.3, 0.4], forKey: "clear-test-2")
        
        // Verify existence
        XCTAssertTrue(vectorStore.exists(forKey: "clear-test-1"))
        XCTAssertTrue(vectorStore.exists(forKey: "clear-test-2"))
        
        // Clear store
        try vectorStore.clear()
        
        // Verify all vectors are deleted
        XCTAssertFalse(vectorStore.exists(forKey: "clear-test-1"))
        XCTAssertFalse(vectorStore.exists(forKey: "clear-test-2"))
        XCTAssertEqual(vectorStore.getAllKeys().count, 0)
    }
}