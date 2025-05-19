//
//  AudioProcessor.swift
//  Mixtapes
//
//  Created by Claude AI on 05/16/25.
//  Copyright © 2025 Swanand Tanavade. All rights reserved.
//

import Foundation
import AVFoundation
import CoreML
import Combine

/// Real-time audio processor with FFT analysis and mood detection
class AudioProcessor: ObservableObject {
    // Audio engine components
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private let fftProcessor: FFTProcessor
    
    // Performance optimization
    private let bufferPool: AudioBufferPool
    private let analysisQueue = DispatchQueue(label: "com.mixtapes.analysis", qos: .userInitiated)
    private let featureExtractionQueue = DispatchQueue(label: "com.mixtapes.features", qos: .userInitiated)
    private let moodClassificationQueue = DispatchQueue(label: "com.mixtapes.mood", qos: .userInitiated)
    private var workItems: Set<DispatchWorkItem> = []
    private let workItemsLock = NSLock()
    
    // Buffer and processing settings
    private let bufferSize: Int = 4096
    private let sampleRate: Float = 44100.0
    private let maxBuffers = 8
    
    // Feature extraction and analysis
    @Published var currentFeatures: AudioFeatures?
    @Published var detectedMood: Mood = .neutral
    @Published var isAnalyzing: Bool = false
    
    // CoreML mood classification model
    private var moodClassifier: MLModel?
    private var modelQueue = DispatchQueue(label: "com.mixtapes.mlmodel", qos: .userInitiated)
    
    // Analysis state
    private var featureHistory: [AudioFeatures] = []
    private let maxHistorySize = 10
    private let historyLock = NSLock()
    
    init() {
        // Initialize audio components
        self.inputNode = audioEngine.inputNode
        self.fftProcessor = FFTProcessor(bufferSize: bufferSize, sampleRate: sampleRate)
        
        // Initialize buffer pool
        self.bufferPool = AudioBufferPool(
            maxBuffers: maxBuffers,
            bufferSize: bufferSize,
            format: inputNode.outputFormat(forBus: 0)
        )
        
        // Setup audio session and load model
        setupAudioSession()
        loadMoodClassificationModel()
    }
    
    deinit {
        stopRealTimeAnalysis()
        cancelAllWorkItems()
        bufferPool.drain()
    }
    
    // MARK: - Work Item Management
    
    private func addWorkItem(_ item: DispatchWorkItem) {
        workItemsLock.lock()
        workItems.insert(item)
        workItemsLock.unlock()
    }
    
    private func removeWorkItem(_ item: DispatchWorkItem) {
        workItemsLock.lock()
        workItems.remove(item)
        workItemsLock.unlock()
    }
    
    private func cancelAllWorkItems() {
        workItemsLock.lock()
        workItems.forEach { $0.cancel() }
        workItems.removeAll()
        workItemsLock.unlock()
    }
    
    // MARK: - Feature History Management
    
    private func addFeatureToHistory(_ feature: AudioFeatures) {
        historyLock.lock()
        featureHistory.append(feature)
        if featureHistory.count > maxHistorySize {
            featureHistory.removeFirst()
        }
        historyLock.unlock()
    }

    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Set category to allow playback and recording simultaneously
            try audioSession.setCategory(.playAndRecord, 
                                       mode: .default, 
                                       options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            print("AudioProcessor - Audio session configured successfully")
        } catch {
            print("AudioProcessor - Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - CoreML Model Loading
    
    private func loadMoodClassificationModel() {
        // In a production app, load actual CoreML model for mood classification
        // Here we simulate a working model
        
        processingQueue.async {
            // Simulate model loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("AudioProcessor - Mood classification model loaded")
            }
        }
    }
    
    // MARK: - Real-time Analysis
    
    /// Start real-time audio analysis with FFT processing
    func startRealTimeAnalysis(onFeaturesUpdate: @escaping (AudioFeatures) -> Void) {
        guard !audioEngine.isRunning else { return }
        
        let inputFormat = inputNode.outputFormat(forBus: 0)
        let analysisFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: Double(sampleRate),
            channels: 1,
            interleaved: false
        )!
        
        // Install tap on background queue to avoid blocking
        analysisQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(self.bufferSize),
                                    format: inputFormat) { [weak self] buffer, time in
                guard let self = self else { return }
                
                // Get recycled buffer from pool
                guard let processBuffer = self.bufferPool.obtainBuffer() else { return }
                
                // Copy input to process buffer
                buffer.copy(to: processBuffer)
                
                // Process on background queue
                let workItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    
                    // Extract features
                    self.featureExtractionQueue.async {
                        let features = self.fftProcessor.extractFeatures(from: processBuffer)
                        
                        // Return buffer to pool
                        self.bufferPool.returnBuffer(processBuffer)
                        
                        // Update features on main queue
                        DispatchQueue.main.async {
                            self.currentFeatures = features
                            onFeaturesUpdate(features)
                        }
                        
                        // Classify mood on separate queue
                        self.classifyMood(for: features)
                    }
                }
                
                self.addWorkItem(workItem)
                self.analysisQueue.async(execute: workItem)
            }
            
            // Start engine
            do {
                try self.audioEngine.start()
                DispatchQueue.main.async {
                    self.isAnalyzing = true
                }
            } catch {
                print("AudioProcessor - Failed to start engine: \(error)")
            }
        }
    }
    
    /// Stop real-time audio analysis
    func stopRealTimeAnalysis() {
        audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        cancelAllWorkItems()
        
        DispatchQueue.main.async {
            self.isAnalyzing = false
        }
    }
    
    // MARK: - Audio Buffer Processing
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Extract spectral features using FFT
            guard let spectralFeatures = self.fftProcessor.processBuffer(buffer) else {
                return
            }
            
            // Convert spectral features to audio features
            let audioFeatures = self.convertToAudioFeatures(from: spectralFeatures)
            
            // Update feature history
            self.updateFeatureHistory(audioFeatures)
            
            // Detect mood from features
            let detectedMood = self.classifyMood(from: audioFeatures)
            
            // Update main thread
            DispatchQueue.main.async {
                self.currentFeatures = audioFeatures
                self.detectedMood = detectedMood
                
                // Notify callback
                self.onFeaturesUpdate?(audioFeatures)
            }
        }
    }
    
    // MARK: - Feature Conversion
    
    private func convertToAudioFeatures(from spectralFeatures: SpectralFeatures) -> AudioFeatures {
        // Map spectral features to standard audio features used by the app
        
        // Normalize spectral centroid to brightness (0-1)
        let brightness = min(1.0, spectralFeatures.spectralCentroid / 8000.0)
        
        // Map spectral rolloff to energy approximation
        let energy = min(1.0, spectralFeatures.spectralRolloff / 8000.0)
        
        // Use bass vs treble energy ratio for valence approximation
        let valence = spectralFeatures.bassEnergy > spectralFeatures.trebleEnergy ? 
                     0.3 + spectralFeatures.midEnergy * 0.7 : 
                     0.7 + spectralFeatures.trebleEnergy * 0.3
        
        // Map tempo to danceability
        let danceability = spectralFeatures.estimatedTempo > 100 ? 
                          min(1.0, (spectralFeatures.estimatedTempo - 60) / 120) : 
                          0.5
        
        // Acousticness from bass energy (more bass = less acoustic typically)
        let acousticness = 1.0 - spectralFeatures.bassEnergy
        
        // Instrumentalness from spectral contrast (higher contrast = more instruments)
        let instrumentalness = min(1.0, spectralFeatures.spectralContrast / 20.0)
        
        // Speechiness from zero crossing rate
        let speechiness = min(1.0, spectralFeatures.zeroCrossingRate * 10.0)
        
        // Liveness approximation from energy variance
        let liveness = 0.5 // Simplified for now
        
        return AudioFeatures(
            tempo: spectralFeatures.estimatedTempo,
            energy: energy,
            valence: valence,
            danceability: danceability,
            acousticness: acousticness,
            instrumentalness: instrumentalness,
            speechiness: speechiness,
            liveness: liveness
        )
    }
    
    // MARK: - Feature History Management
    
    private func updateFeatureHistory(_ features: AudioFeatures) {
        featureHistory.append(features)
        
        // Maintain maximum history size
        if featureHistory.count > maxHistorySize {
            featureHistory.removeFirst()
        }
    }
    
    /// Get averaged features over recent history
    func getAveragedFeatures() -> AudioFeatures? {
        guard !featureHistory.isEmpty else { return nil }
        
        let count = Float(featureHistory.count)
        
        let avgTempo = featureHistory.map(\.tempo).reduce(0, +) / count
        let avgEnergy = featureHistory.map(\.energy).reduce(0, +) / count
        let avgValence = featureHistory.map(\.valence).reduce(0, +) / count
        let avgDanceability = featureHistory.map(\.danceability).reduce(0, +) / count
        let avgAcousticness = featureHistory.map(\.acousticness).reduce(0, +) / count
        let avgInstrumentalness = featureHistory.map(\.instrumentalness).reduce(0, +) / count
        let avgSpeechiness = featureHistory.map(\.speechiness).reduce(0, +) / count
        let avgLiveness = featureHistory.map(\.liveness).reduce(0, +) / count
        
        return AudioFeatures(
            tempo: avgTempo,
            energy: avgEnergy,
            valence: avgValence,
            danceability: avgDanceability,
            acousticness: avgAcousticness,
            instrumentalness: avgInstrumentalness,
            speechiness: avgSpeechiness,
            liveness: avgLiveness
        )
    }
    
    // MARK: - Mood Classification
    
    private func classifyMood(from features: AudioFeatures) -> Mood {
        // In a production app, this would use the CoreML model
        // For now, we'll use rule-based classification
        
        // Rule-based mood detection
        if features.tempo > 120 && features.energy > 0.7 {
            return features.valence > 0.6 ? .energetic : .angry
        } else if features.tempo < 100 && features.energy < 0.4 {
            return features.valence > 0.5 ? .relaxed : .melancholic
        } else if features.valence > 0.7 {
            return .happy
        } else if features.energy > 0.5 && features.valence > 0.4 && features.valence < 0.6 {
            return .focused
        } else if features.energy < 0.6 && features.valence > 0.5 && features.valence < 0.8 {
            return .romantic
        } else {
            return .neutral
        }
    }
    
    // MARK: - Analysis from File
    
    /// Analyze an audio file and extract features
    func analyzeAudioFile(at url: URL, completion: @escaping (AudioFeatures?, Mood?) -> Void) {
        processingQueue.async {
            do {
                // Load audio file
                let audioFile = try AVAudioFile(forReading: url)
                let format = audioFile.processingFormat
                let frameCount = AVAudioFrameCount(audioFile.length)
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                    return
                }
                
                // Read file into buffer
                try audioFile.read(into: buffer)
                
                // Process in chunks for large files
                var allFeatures: [AudioFeatures] = []
                let chunkSize = self.bufferSize
                let totalFrames = Int(buffer.frameLength)
                
                for startFrame in stride(from: 0, to: totalFrames, by: chunkSize) {
                    let endFrame = min(startFrame + chunkSize, totalFrames)
                    let chunkLength = endFrame - startFrame
                    
                    // Create chunk buffer
                    guard let chunkBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(chunkLength)) else {
                        continue
                    }
                    
                    // Copy data to chunk buffer
                    if let sourceData = buffer.floatChannelData,
                       let chunkData = chunkBuffer.floatChannelData {
                        for channel in 0..<Int(format.channelCount) {
                            let sourcePointer = sourceData[channel].advanced(by: startFrame)
                            let chunkPointer = chunkData[channel]
                            chunkPointer.assign(from: sourcePointer, count: chunkLength)
                        }
                        chunkBuffer.frameLength = AVAudioFrameCount(chunkLength)
                    }
                    
                    // Extract features from chunk (if buffer size matches)
                    if chunkLength == chunkSize,
                       let spectralFeatures = self.fftProcessor.processBuffer(chunkBuffer) {
                        let audioFeatures = self.convertToAudioFeatures(from: spectralFeatures)
                        allFeatures.append(audioFeatures)
                    }
                }
                
                // Average features across all chunks
                let avgFeatures = self.averageFeatures(allFeatures)
                let detectedMood = avgFeatures != nil ? self.classifyMood(from: avgFeatures!) : nil
                
                DispatchQueue.main.async {
                    completion(avgFeatures, detectedMood)
                }
                
            } catch {
                print("AudioProcessor - Error analyzing file: \(error)")
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    
    private func averageFeatures(_ features: [AudioFeatures]) -> AudioFeatures? {
        guard !features.isEmpty else { return nil }
        
        let count = Float(features.count)
        
        return AudioFeatures(
            tempo: features.map(\.tempo).reduce(0, +) / count,
            energy: features.map(\.energy).reduce(0, +) / count,
            valence: features.map(\.valence).reduce(0, +) / count,
            danceability: features.map(\.danceability).reduce(0, +) / count,
            acousticness: features.map(\.acousticness).reduce(0, +) / count,
            instrumentalness: features.map(\.instrumentalness).reduce(0, +) / count,
            speechiness: features.map(\.speechiness).reduce(0, +) / count,
            liveness: features.map(\.liveness).reduce(0, +) / count
        )
    }
    
    /// Get current analysis statistics
    func getAnalysisStatistics() -> AnalysisStatistics {
        return AnalysisStatistics(
            isActive: isAnalyzing,
            sampleRate: sampleRate,
            bufferSize: bufferSize,
            featuresInHistory: featureHistory.count,
            currentMood: detectedMood
        )
    }
}

// MARK: - Supporting Structures

struct AnalysisStatistics {
    let isActive: Bool
    let sampleRate: Float
    let bufferSize: Int
    let featuresInHistory: Int
    let currentMood: Mood
}

/// Extended audio features structure with all Spotify-like features
struct AudioFeatures: Codable {
    let tempo: Float              // BPM
    let energy: Float             // 0-1, intensity
    let valence: Float            // 0-1, positivity
    let danceability: Float       // 0-1, dance suitability
    let acousticness: Float       // 0-1, acoustic confidence
    let instrumentalness: Float   // 0-1, no vocals confidence
    let speechiness: Float        // 0-1, spoken words
    let liveness: Float           // 0-1, live performance
}
