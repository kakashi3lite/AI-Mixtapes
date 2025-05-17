import Foundation

struct SpeakerSegment {
    var text: String
    var start: TimeInterval
    var end: TimeInterval
    var speakerId: String
    var confidence: Float
    // Add new properties
    var embeddingVector: [Float]?
    var clusterId: Int?
}

class TranscriptionService {
    private let whisperService: WhisperService
    
    init(whisperService: WhisperService) {
        self.whisperService = whisperService
    }
    
    func transcribeAudio(url: URL) async throws -> [SpeakerSegment] {
        // Existing transcription logic
        let rawSegments = try await whisperService.transcribe(audioURL: url)
        
        // Generate embeddings for each segment
        var segmentsWithEmbeddings = rawSegments.map { segment in
            var updatedSegment = segment
            updatedSegment.embeddingVector = whisperService.generateEmbedding(for: segment.text)
            return updatedSegment
        }
        
        // Perform speaker diarization
        segmentsWithEmbeddings = performSpeakerDiarization(segments: segmentsWithEmbeddings)
        
        return segmentsWithEmbeddings
    }
    
    private func performSpeakerDiarization(segments: [SpeakerSegment]) -> [SpeakerSegment] {
        // Extract embeddings
        let vectors = segments.compactMap { $0.embeddingVector }
        guard vectors.count == segments.count else { return segments }
        
        // K-means clustering
        let k = min(4, segments.count) // Reasonable speaker limit
        let clusters = KMeans(k: k).fit(vectors: vectors)
        
        // Assign cluster IDs
        return segments.enumerated().map { (index, segment) in
            var updatedSegment = segment
            updatedSegment.clusterId = clusters.labels[index]
            updatedSegment.speakerId = "Speaker-\(clusters.labels[index] + 1)"
            return updatedSegment
        }
    }
}

class KMeans {
    let k: Int
    var centroids: [[Float]] = []
    var labels: [Int] = []
    
    init(k: Int) {
        self.k = k
    }
    
    func fit(vectors: [[Float]]) -> KMeans {
        guard vectors.count >= k, k > 0 else {
            // Fallback for invalid input
            labels = Array(repeating: 0, count: vectors.count)
            return self
        }
        
        // Initialize centroids with random points
        centroids = Array(vectors.shuffled().prefix(k))
        
        // Run clustering algorithm (simplified)
        for _ in 0..<10 { // Max 10 iterations
            // Assign each point to nearest centroid
            labels = vectors.map { vector in
                return findNearestCentroid(vector: vector)
            }
            
            // Update centroids
            for i in 0..<k {
                let clusterPoints = vectors.enumerated()
                    .filter { labels[$0.offset] == i }
                    .map { $0.element }
                
                if !clusterPoints.isEmpty {
                    centroids[i] = calculateMean(vectors: clusterPoints)
                }
            }
        }
        
        return self
    }
    
    private func findNearestCentroid(vector: [Float]) -> Int {
        var minDistance = Float.infinity
        var nearestIndex = 0
        
        for (i, centroid) in centroids.enumerated() {
            let distance = calculateDistance(a: vector, b: centroid)
            if distance < minDistance {
                minDistance = distance
                nearestIndex = i
            }
        }
        
        return nearestIndex
    }
    
    private func calculateDistance(a: [Float], b: [Float]) -> Float {
        // Euclidean distance
        let dimensions = min(a.count, b.count)
        var sum: Float = 0
        
        for i in 0..<dimensions {
            let diff = a[i] - b[i]
            sum += diff * diff
        }
        
        return sqrt(sum)
    }
    
    private func calculateMean(vectors: [[Float]]) -> [Float] {
        guard !vectors.isEmpty, let firstVector = vectors.first else {
            return []
        }
        
        let dimensions = firstVector.count
        var mean = Array(repeating: Float(0), count: dimensions)
        
        for vector in vectors {
            for i in 0..<dimensions {
                mean[i] += vector[i]
            }
        }
        
        for i in 0..<dimensions {
            mean[i] /= Float(vectors.count)
        }
        
        return mean
    }
}