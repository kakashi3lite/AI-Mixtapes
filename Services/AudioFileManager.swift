import Foundation
import AVFoundation
import CoreData

/// Service for managing local audio files and playback
class AudioFileManager {
    private let fileManager = FileManager.default
    private let documentsPath: String
    private let cachePath: String
    
    // Audio file types supported
    private let supportedTypes = ["mp3", "m4a", "wav", "aac"]
    
    init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        
        // Create directories if needed
        createDirectories()
    }
    
    // MARK: - Directory Management
    
    private func createDirectories() {
        let paths = [
            documentsPath + "/MixTapes",
            cachePath + "/AudioCache"
        ]
        
        for path in paths {
            if !fileManager.fileExists(atPath: path) {
                try? fileManager.createDirectory(
                    atPath: path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
        }
    }
    
    // MARK: - File Management
    
    /// Save an audio file to local storage
    func saveAudioFile(_ audioData: Data, filename: String) throws -> URL {
        let fileURL = URL(fileURLWithPath: documentsPath)
            .appendingPathComponent("MixTapes")
            .appendingPathComponent(filename)
        
        try audioData.write(to: fileURL)
        return fileURL
    }
    
    /// Cache an audio file from remote URL
    func cacheAudioFile(from remoteURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let filename = remoteURL.lastPathComponent
        let cacheURL = URL(fileURLWithPath: cachePath)
            .appendingPathComponent("AudioCache")
            .appendingPathComponent(filename)
        
        // Check if already cached
        if fileManager.fileExists(atPath: cacheURL.path) {
            completion(.success(cacheURL))
            return
        }
        
        // Download and cache
        URLSession.shared.downloadTask(with: remoteURL) { tempURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let tempURL = tempURL else {
                completion(.failure(NSError(domain: "AudioFileManager", code: -1)))
                return
            }
            
            do {
                try self.fileManager.moveItem(at: tempURL, to: cacheURL)
                completion(.success(cacheURL))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Get audio file metadata
    func getAudioMetadata(for url: URL) throws -> [String: Any] {
        let asset = AVAsset(url: url)
        var metadata: [String: Any] = [:]
        
        // Get common metadata
        let commonMetadata = asset.commonMetadata
        
        for item in commonMetadata {
            if let key = item.commonKey?.rawValue,
               let value = try? item.load(.value) {
                metadata[key] = value
            }
        }
        
        // Get duration
        if let duration = try? await asset.load(.duration) {
            metadata["duration"] = duration.seconds
        }
        
        return metadata
    }
    
    /// Clean up cached files older than specified days
    func cleanupCache(olderThan days: Int = 7) {
        let cacheURL = URL(fileURLWithPath: cachePath).appendingPathComponent("AudioCache")
        guard let files = try? fileManager.contentsOfDirectory(
            at: cacheURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        ) else { return }
        
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(days * 24 * 60 * 60))
        
        for file in files {
            guard let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                  let creationDate = attributes[.creationDate] as? Date else { continue }
            
            if creationDate < cutoffDate {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    // MARK: - Playlist Management
    
    /// Create a local playlist file for a mixtape
    func createPlaylistFile(for mixtape: MixTape) throws -> URL {
        let playlistData = try JSONEncoder().encode(
            mixtape.songsArray.map { ["url": $0.url, "title": $0.title] }
        )
        
        let playlistURL = URL(fileURLWithPath: documentsPath)
            .appendingPathComponent("MixTapes")
            .appendingPathComponent("\(mixtape.id.uuidString).playlist")
        
        try playlistData.write(to: playlistURL)
        return playlistURL
    }
    
    /// Load a playlist file
    func loadPlaylistFile(at url: URL) throws -> [[String: Any]] {
        let data = try Data(contentsOf: url)
        return try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
    }
}
