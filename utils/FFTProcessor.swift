import Foundation
import Accelerate
import AVFoundation

/// Utility class for performing FFT analysis on audio data
class FFTProcessor {
    // FFT configuration
    private let fftSetup: vDSP_DFT_Setup?
    private let bufferSize: Int
    private let sampleRate: Float
    
    // Reusable buffers for FFT processing
    private let window: [Float]
    private var reusableBuffer: [Float]
    private var reusableImaginary: [Float]
    private var reusableMagnitudes: [Float]
    private let bufferLock = NSLock()
    
    // Frequency bands for analysis
    private let bassRange: ClosedRange<Float> = 20...250
    private let midRange: ClosedRange<Float> = 250...2000
    private let trebleRange: ClosedRange<Float> = 2000...8000
    
    // Analysis state
    private var lastMagnitudes: [Float]?
    private var timeLastBeat: Float = 0
    private var beatHistory: [Float] = []
    
    init(bufferSize: Int, sampleRate: Float) {
        self.bufferSize = bufferSize
        self.sampleRate = sampleRate
        
        // Create Hanning window for better frequency response
        self.window = vDSP.window(ofType: Float.self,
                                usingSequence: .hannNormalized,
                                count: bufferSize,
                                isHalfWindow: false)
        
        // Initialize reusable buffers
        self.reusableBuffer = Array(repeating: 0, count: bufferSize)
        self.reusableImaginary = Array(repeating: 0, count: bufferSize)
        self.reusableMagnitudes = Array(repeating: 0, count: bufferSize)
        
        // Create FFT setup
        self.fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            vDSP_Length(bufferSize),
            .FORWARD
        )
    }
    
    deinit {
        if let setup = fftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
    }
    
    /// Process audio buffer and extract spectral features
    func processBuffer(_ buffer: AVAudioPCMBuffer) -> SpectralFeatures? {
        bufferLock.lock()
        defer { bufferLock.unlock() }
        
        // Get audio data
        guard let channelData = buffer.floatChannelData?[0] else {
            return nil
        }
        
        // Copy samples to reusable buffer and apply window
        vDSP.multiply(channelData,
                     window,
                     result: &reusableBuffer)
        
        // Perform FFT
        vDSP_DFT_Execute(
            fftSetup!,
            reusableBuffer,
            reusableImaginary,
            &reusableBuffer,
            &reusableImaginary
        )
        
        // Calculate magnitude spectrum
        vDSP.absolute(
            DSPSplitComplex(
                realp: &reusableBuffer,
                imagp: &reusableImaginary
            ),
            result: &reusableMagnitudes
        )
        
        // Extract features
        let spectralCentroid = calculateSpectralCentroid(magnitudes: reusableMagnitudes)
        let spectralRolloff = calculateSpectralRolloff(magnitudes: reusableMagnitudes)
        let spectralFlux = calculateSpectralFlux()
        let spectralContrast = calculateSpectralContrast()
        
        // Calculate energy in different frequency bands
        let bassEnergy = calculateBandEnergy(range: bassRange)
        let midEnergy = calculateBandEnergy(range: midRange)
        let trebleEnergy = calculateBandEnergy(range: trebleRange)
        
        // Estimate tempo and beat strength
        let (estimatedTempo, beatStrength) = estimateTempoAndBeatStrength()
        
        // Store current magnitudes for next flux calculation
        lastMagnitudes = reusableMagnitudes
        
        return SpectralFeatures(
            spectralCentroid: spectralCentroid,
            spectralRolloff: spectralRolloff,
            spectralFlux: spectralFlux,
            spectralContrast: spectralContrast,
            zeroCrossingRate: calculateZeroCrossingRate(buffer),
            dynamicRange: calculateDynamicRange(),
            bassEnergy: bassEnergy,
            midEnergy: midEnergy,
            trebleEnergy: trebleEnergy,
            estimatedTempo: estimatedTempo,
            beatStrength: beatStrength
        )
    }
    
    // MARK: - Feature Calculation Methods
    
    private func calculateSpectralCentroid(magnitudes: [Float]) -> Float {
        let frequencies = (0..<bufferSize).map { Float($0) * sampleRate / Float(bufferSize) }
        var weightedSum: Float = 0
        var magnitudeSum: Float = 0
        
        vDSP.multiply(frequencies,
                     magnitudes,
                     result: &reusableBuffer)
        
        weightedSum = vDSP.sum(reusableBuffer)
        magnitudeSum = vDSP.sum(magnitudes)
        
        return magnitudeSum > 0 ? weightedSum / magnitudeSum : 0
    }
    
    private func calculateSpectralRolloff(magnitudes: [Float], percentage: Float = 0.85) -> Float {
        let totalEnergy = magnitudes.reduce(0, +)
        let threshold = totalEnergy * percentage
        var accumulator: Float = 0
        
        for i in 0..<bufferSize/2 {
            accumulator += magnitudes[i]
            if accumulator >= threshold {
                return frequencies[i]
            }
        }
        return nyquistFrequency
    }
    
    private func calculateSpectralFlux() -> Float {
        guard let lastMags = lastMagnitudes else { return 0 }
        
        var flux: Float = 0
        for i in 0..<bufferSize/2 {
            let diff = reusableMagnitudes[i] - lastMags[i]
            flux += diff * diff
        }
        return sqrt(flux)
    }
    
    private func calculateSpectralContrast() -> Float {
        let valleyBins = 5
        let peakBins = 5
        
        let sortedMagnitudes = reusableMagnitudes.sorted()
        let valleys = sortedMagnitudes[..<valleyBins].reduce(0, +) / Float(valleyBins)
        let peaks = sortedMagnitudes[(bufferSize/2 - peakBins)...].reduce(0, +) / Float(peakBins)
        
        return peaks - valleys
    }
    
    private func calculateZeroCrossingRate(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let data = buffer.floatChannelData?[0] else { return 0 }
        
        var crossings: Int = 0
        for i in 1..<bufferSize {
            if data[i-1] * data[i] < 0 {
                crossings += 1
            }
        }
        
        return Float(crossings) / Float(bufferSize)
    }
    
    private func calculateDynamicRange() -> Float {
        let sortedMagnitudes = reusableMagnitudes.sorted()
        let p90 = sortedMagnitudes[Int(Float(bufferSize/2) * 0.9)]
        let p10 = sortedMagnitudes[Int(Float(bufferSize/2) * 0.1)]
        return p90 - p10
    }
    
    private func calculateBandEnergy(range: ClosedRange<Float>) -> Float {
        var energy: Float = 0
        var count: Int = 0
        
        for i in 0..<bufferSize/2 {
            if range.contains(frequencies[i]) {
                energy += magnitudes[i]
                count += 1
            }
        }
        
        return count > 0 ? energy / Float(count) : 0
    }
    
    private func estimateTempoAndBeatStrength() -> (tempo: Float, strength: Float) {
        let energyChange = calculateSpectralFlux()
        let currentTime = Float(Date().timeIntervalSince1970)
        
        if energyChange > 0.5 && (currentTime - timeLastBeat) > 0.2 {  // 200ms minimum between beats
            let beatInterval = currentTime - timeLastBeat
            timeLastBeat = currentTime
            
            beatHistory.append(beatInterval)
            if beatHistory.count > 8 { beatHistory.removeFirst() }
        }
        
        // Calculate tempo from beat history
        if beatHistory.isEmpty { return (0, 0) }
        
        let averageInterval = beatHistory.reduce(0, +) / Float(beatHistory.count)
        let tempo = 60.0 / averageInterval  // Convert to BPM
        
        // Calculate beat strength based on consistency
        let variance = beatHistory.map { pow($0 - averageInterval, 2) }.reduce(0, +) / Float(beatHistory.count)
        let beatStrength = 1.0 / (1.0 + variance)  // Normalize to 0-1 range
        
        return (tempo, beatStrength)
    }
}

/// Structure containing extracted spectral features
struct SpectralFeatures {
    let spectralCentroid: Float      // Weighted mean of frequencies
    let spectralRolloff: Float       // Frequency below which 85% of energy exists
    let spectralFlux: Float          // Rate of change of spectrum
    let spectralContrast: Float      // Difference between peaks and valleys
    let zeroCrossingRate: Float      // Rate of signal sign-changes
    let dynamicRange: Float          // Difference between loudest and quietest parts
    let bassEnergy: Float           // Energy in low frequencies
    let midEnergy: Float            // Energy in mid frequencies
    let trebleEnergy: Float         // Energy in high frequencies
    let estimatedTempo: Float       // Estimated BPM
    let beatStrength: Float         // Confidence in beat detection (0-1)
}
