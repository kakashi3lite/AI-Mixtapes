import XCTest
@testable import AI_Mixtapes
import CoreData

class AIIntegrationServiceTests: XCTestCase {
    var aiService: AIIntegrationService!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        // Set up in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "AI_Mixtapes")
        container.persistentStoreDescriptor = NSPersistentStoreDescription()
        container.persistentStoreDescriptor.type = NSInMemoryStoreType
        
        container.loadPersistentStores { description, error in
            XCTAssertNil(error)
        }
        context = container.viewContext
        
        // Initialize service
        aiService = AIIntegrationService(context: context)
    }
    
    override func tearDown() {
        aiService = nil
        context = nil
        super.tearDown()
    }
    
    // Test mood detection integration with Anthropic
    func testMoodDetection() {
        let expectation = XCTestExpectation(description: "Mood detection")
        
        // Create test song with audio features
        let song = Song(context: context)
        song.name = "Test Song"
        song.audioFeatures = mockAudioFeatures()
        
        aiService.enhanceMoodDetection(forSong: song) { result in
            switch result {
            case .success(let mood):
                XCTAssertNotNil(mood)
                XCTAssertTrue(Mood.allCases.contains(mood))
            case .failure(let error):
                XCTFail("Mood detection failed: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test playlist recommendations with Anthropic
    func testPlaylistRecommendations() {
        let expectation = XCTestExpectation(description: "Recommendations")
        
        aiService.getAIPlaylistSuggestions(currentMood: .happy) { mixtapes in
            XCTAssertFalse(mixtapes.isEmpty)
            
            // Verify recommendation properties
            if let firstMixtape = mixtapes.first {
                XCTAssertTrue(firstMixtape.aiGenerated)
                XCTAssertNotNil(firstMixtape.moodTags)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Test interaction tracking
    func testInteractionTracking() {
        // Create test mixtape
        let mixtape = MixTape(context: context)
        mixtape.title = "Test Mixtape"
        
        // Track an interaction
        aiService.trackInteraction(type: "play_song", mixtape: mixtape)
        
        // Verify that personality and mood engines received the interaction
        XCTAssertTrue(aiService.personalityEngine.currentPersonality != .unknown)
        XCTAssertTrue(aiService.moodEngine.currentMood != .unknown)
    }
    
    // Test integration between services 
    func testServiceIntegration() {
        // Test that mood changes affect recommendations
        aiService.moodEngine.currentMood = .energetic
        
        let expectation = XCTestExpectation(description: "Service integration")
        
        aiService.getAIPlaylistSuggestions(currentMood: .energetic) { mixtapes in
            XCTAssertFalse(mixtapes.isEmpty)
            
            // Verify mood influenced the recommendations
            if let firstMixtape = mixtapes.first,
               let moodTags = firstMixtape.moodTags {
                XCTAssertTrue(moodTags.contains("energetic"))
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Helper function to create mock audio features
    private func mockAudioFeatures() -> Data? {
        let features = AudioFeatures(
            tempo: 120.0,
            energy: 0.8,
            spectralCentroid: 0.6,
            valence: 0.7,
            danceability: 0.9,
            acousticness: 0.3,
            instrumentalness: 0.4,
            speechiness: 0.1,
            liveness: 0.2
        )
        return try? JSONEncoder().encode(features)
    }
}
