import Foundation
import XCTest
import CoreData
@testable import AI_Mixtapes

class TestHelpers {
    // Create an in-memory Core Data stack for testing
    static func createTestCoreDataStack() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "AI_Mixtapes")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        return container
    }
    
    // Create a mock audio file URL
    static func createMockAudioURL() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: documentsPath).appendingPathComponent("test.mp3")
    }
    
    // Create mock audio features
    static func createMockAudioFeatures() -> AudioFeatures {
        return AudioFeatures(
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
    }
    
    // Create a mock mixtape entity
    static func createMockMixtape(in context: NSManagedObjectContext) -> MixTape {
        let mixtape = MixTape(context: context)
        mixtape.title = "Test Mixtape"
        mixtape.numberOfSongs = 0
        mixtape.aiGenerated = true
        mixtape.moodTags = "happy,energetic"
        mixtape.lastPlayedDate = Date()
        return mixtape
    }
    
    // Create a mock song entity
    static func createMockSong(in context: NSManagedObjectContext) -> Song {
        let song = Song(context: context)
        song.name = "Test Song"
        song.positionInTape = 0
        song.playCount = 0
        
        // Add mock audio features
        let features = createMockAudioFeatures()
        song.audioFeatures = try? JSONEncoder().encode(features)
        
        return song
    }
    
    // Mock Anthropic API response
    static func mockAnthropicResponse(for request: String) -> Data {
        let response = [
            "messages": [
                [
                    "role": "assistant",
                    "content": "Mock response for: \(request)"
                ]
            ]
        ]
        return try! JSONSerialization.data(withJSONObject: response)
    }
    
    // Create mock weather response
    static func mockWeatherResponse(for location: String) -> String {
        return "The weather in \(location) is sunny with a high of 75°F"
    }
}
