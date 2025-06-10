import Foundation

struct Mixtape: Identifiable {
    let id: UUID
    var name: String
    var mood: String
    var songs: [Song]
    var createdAt: Date
    var coverArt: String?
    var duration: TimeInterval
    
    init(id: UUID = UUID(), name: String, mood: String, songs: [Song] = [], createdAt: Date = Date(), coverArt: String? = nil) {
        self.id = id
        self.name = name
        self.mood = mood
        self.songs = songs
        self.createdAt = createdAt
        self.coverArt = coverArt
        self.duration = songs.reduce(0) { $0 + $1.duration }
    }
}

struct Song: Identifiable {
    let id: UUID
    var title: String
    var artist: String
    var duration: TimeInterval
    var audioFeatures: AudioFeatures?
}

struct MoodEntry: Identifiable {
    let id: UUID
    var mood: String
    var timestamp: Date
    var intensity: Double
}
