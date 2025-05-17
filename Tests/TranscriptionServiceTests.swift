import XCTest
@testable import AI_Mixtapes

class TranscriptionServiceTests: XCTestCase {
    var whisperService: MockWhisperService!
    var transcriptionService: TranscriptionService!
    
    override func setUp() {
        super.setUp()
        whisperService = MockWhisperService()
        transcriptionService = TranscriptionService(whisperService: whisperService)
    }
    
    override func tearDown() {
        whisperService = nil
        transcriptionService = nil
        super.tearDown()
    }
    
    func testTranscriptionWithDiarization() async throws {
        // Set up mock data with embedding vectors
        let mockSegments = [
            createSegment(text: "Hello there", embedding: [0.1, 0.2, 0.3]),
            createSegment(text: "How are you?", embedding: [0.15, 0.25, 0.35]),
            createSegment(text: "I'm doing great!", embedding: [0.8, 0.7, 0.9]),
            createSegment(text: "That's wonderful to hear.", embedding: [0.85, 0.75, 0.95])
        ]
        
        whisperService.mockSegments = mockSegments
        
        // Test transcription with diarization
        let result = try await transcriptionService.transcribeAudio(url: URL(fileURLWithPath: "test.m4a"))
        
        // Verify results
        XCTAssertEqual(result.count, mockSegments.count)
        
        // Check that all segments have cluster IDs
        for segment in result {
            XCTAssertNotNil(segment.clusterId)
            XCTAssertNotNil(segment.speakerId)
        }
        
        // Verify that similar embeddings got clustered together
        let segment0ClusterId = result[0].clusterId
        let segment1ClusterId = result[1].clusterId
        let segment2ClusterId = result[2].clusterId
        let segment3ClusterId = result[3].clusterId
        
        // First two segments should have the same cluster ID (similar embeddings)
        XCTAssertEqual(segment0ClusterId, segment1ClusterId)
        
        // Last two segments should have the same cluster ID (similar embeddings)
        XCTAssertEqual(segment2ClusterId, segment3ClusterId)
        
        // First and last clusters should be different
        XCTAssertNotEqual(segment0ClusterId, segment2ClusterId)
    }
    
    private func createSegment(text: String, embedding: [Float]) -> SpeakerSegment {
        var segment = SpeakerSegment(
            text: text,
            start: 0.0,
            end: 1.0,
            speakerId: "",
            confidence: 1.0
        )
        segment.embeddingVector = embedding
        return segment
    }
}

class MockWhisperService: WhisperService {
    var mockSegments: [SpeakerSegment] = []
    
    func transcribe(audioURL: URL) async throws -> [SpeakerSegment] {
        return mockSegments
    }
    
    func generateEmbedding(for text: String) -> [Float] {
        // Return the pre-defined embedding for this segment
        if let segment = mockSegments.first(where: { $0.text == text }) {
            return segment.embeddingVector ?? []
        }
        return []
    }
}