import Foundation
import AVFoundation

/// Thread-safe buffer pool for efficient audio buffer reuse
class AudioBufferPool {
    private let maxBuffers: Int
    private let bufferSize: Int
    private var availableBuffers: [AVAudioPCMBuffer]
    private let queue = DispatchQueue(label: "com.mixtapes.bufferPool")
    
    init(maxBuffers: Int, bufferSize: Int, format: AVAudioFormat) {
        self.maxBuffers = maxBuffers
        self.bufferSize = bufferSize
        self.availableBuffers = []
        
        // Pre-allocate buffers
        for _ in 0..<maxBuffers {
            if let buffer = AVAudioPCMBuffer(pcmFormat: format,
                                           frameCapacity: AVAudioFrameCount(bufferSize)) {
                availableBuffers.append(buffer)
            }
        }
    }
    
    func obtainBuffer() -> AVAudioPCMBuffer? {
        return queue.sync {
            return availableBuffers.isEmpty ? nil : availableBuffers.removeLast()
        }
    }
    
    func returnBuffer(_ buffer: AVAudioPCMBuffer) {
        queue.sync {
            if availableBuffers.count < maxBuffers {
                buffer.frameLength = 0 // Reset buffer
                availableBuffers.append(buffer)
            }
        }
    }
    
    func drain() {
        queue.sync {
            availableBuffers.removeAll()
        }
    }
}
