import SwiftUI
import AVFoundation

struct AudioVisualizationView: View {
    @ObservedObject var aiService: AIIntegrationService
    let audioProcessor: AudioProcessor
    
    // Audio state
    @State private var waveformData: [Float] = []
    @State private var spectrumData: [Float] = []
    @State private var currentFeatures: AudioFeatures?
    @State private var isAnalyzing = false
    
    // Error handling
    @State private var currentError: AppError?
    @State private var retryAction: (() -> Void)?
    
    // Visualization settings
    private let maxPoints = 100
    private let updateInterval: TimeInterval = 0.05
    private let barSpacing: CGFloat = 2
    
    var body: some View {
        VStack(spacing: 20) {
            // Current song visualization
            ZStack {
                // Frequency visualization
                FrequencyVisualizer(audioData: audioProcessor.currentFeatures?.spectralData ?? [])
                    .frame(height: 200)
                
                // Mood overlay
                if let features = audioProcessor.currentFeatures {
                    MoodIndicatorOverlay(
                        mood: aiService.moodEngine.currentMood,
                        confidence: aiService.moodEngine.moodConfidence,
                        energy: features.energy,
                        tempo: features.tempo
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(radius: 10)
            )
            
            // Audio features with mood context
            VStack(spacing: 16) {
                AudioFeatureRow(
                    title: "Energy",
                    value: audioProcessor.currentFeatures?.energy ?? 0,
                    icon: "bolt.fill",
                    color: aiService.moodEngine.currentMood.color
                )
                
                AudioFeatureRow(
                    title: "Tempo",
                    value: audioProcessor.currentFeatures?.tempo ?? 0,
                    icon: "metronome",
                    color: aiService.moodEngine.currentMood.color
                )
                
                AudioFeatureRow(
                    title: "Mood Confidence",
                    value: aiService.moodEngine.moodConfidence,
                    icon: aiService.moodEngine.currentMood.systemIcon,
                    color: aiService.moodEngine.currentMood.color
                )
            }
            .padding()
            
            // Live mood transitions
            if isAnalyzing {
                MoodTransitionView(
                    currentMood: aiService.moodEngine.currentMood,
                    previousMood: aiService.moodEngine.previousMood,
                    transition: aiService.moodEngine.moodTransition
                )
                .transition(.move(edge: .bottom))
            }
        }
        .padding()
        .onAppear(perform: startAnalysis)
        .onDisappear(perform: stopAnalysis)
        .withErrorHandling()
    }
    
    // MARK: - Subviews
    
    private var waveformView: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midY = height / 2
                let pointSpacing = width / CGFloat(waveformData.count - 1)
                
                path.move(to: CGPoint(x: 0, y: midY))
                
                for (index, value) in waveformData.enumerated() {
                    let x = CGFloat(index) * pointSpacing
                    let y = midY + CGFloat(value) * midY
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
            .animation(.linear(duration: updateInterval), value: waveformData)
        }
        .frame(height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var spectrumView: some View {
        GeometryReader { geometry in
            HStack(spacing: barSpacing) {
                ForEach(Array(spectrumData.enumerated()), id: \.offset) { _, magnitude in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: (geometry.size.width - CGFloat(spectrumData.count) * barSpacing) / CGFloat(spectrumData.count))
                        .frame(height: geometry.size.height * CGFloat(magnitude))
                        .animation(.linear(duration: updateInterval), value: magnitude)
                }
            }
        }
        .frame(height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var placeholderView: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .frame(height: 100)
            .cornerRadius(8)
            .overlay(
                Text("No audio signal")
                    .foregroundColor(.secondary)
            )
    }
    
    private func audioFeaturesView(_ features: AudioFeatures) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audio Features")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                featureRow("Energy", value: features.energy)
                featureRow("Valence", value: features.valence)
                featureRow("Danceability", value: features.danceability)
                featureRow("Acousticness", value: features.acousticness)
                featureRow("Instrumentalness", value: features.instrumentalness)
                featureRow("Speechiness", value: features.speechiness)
                featureRow("Liveness", value: features.liveness)
                featureRow("Tempo", value: Float(features.tempo) / 200.0)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func featureRow(_ title: String, value: Float) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: geometry.size.width)
                     
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(value))
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
            
            Text(String(format: "%.2f", value))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Audio Analysis
    
    private func startAnalysis() {
        isAnalyzing = true
        
        do {
            try audioProcessor.startRealTimeAnalysis { features in
                updateVisualization(with: features)
            }
        } catch {
            handleAnalysisError(error)
        }
    }
    
    private func stopAnalysis() {
        isAnalyzing = false
        audioProcessor.stopRealTimeAnalysis()
    }
    
    private func updateVisualization(with features: AudioFeatures) {
        // Update waveform
        waveformData = generateWaveformData()
        
        // Update spectrum
        spectrumData = generateSpectrumData()
        
        // Update features
        currentFeatures = features
    }
    
    private func generateWaveformData() -> [Float] {
        // Simulated waveform data for demo
        var data: [Float] = []
        for _ in 0..<maxPoints {
            data.append(Float.random(in: -1...1))
        }
        return data
    }
    
    private func generateSpectrumData() -> [Float] {
        // Simulated spectrum data for demo
        var data: [Float] = []
        for _ in 0..<maxPoints/2 {
            data.append(Float.random(in: 0...1))
        }
        return data
    }
    
    private func handleAnalysisError(_ error: Error) {
        isAnalyzing = false
        currentError = error as? AppError ?? .audioProcessingFailed(error)
        retryAction = startAnalysis
    }
}

struct FrequencyVisualizer: View {
    let audioData: [Float]
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Draw frequency bars
                let barWidth = size.width / CGFloat(audioData.count)
                let maxAmplitude = audioData.max() ?? 1.0
                
                for (index, amplitude) in audioData.enumerated() {
                    let normalizedAmplitude = CGFloat(amplitude / maxAmplitude)
                    let x = CGFloat(index) * barWidth
                    let height = size.height * normalizedAmplitude
                    
                    let bar = Path(CGRect(
                        x: x,
                        y: size.height - height,
                        width: barWidth * 0.8,
                        height: height
                    ))
                    
                    context.fill(
                        bar,
                        with: .linearGradient(
                            Gradient(colors: [.blue, .purple]),
                            startPoint: CGPoint(x: 0, y: size.height),
                            endPoint: CGPoint(x: 0, y: 0)
                        )
                    )
                }
                
                // Add glow effect
                context.addFilter(.blur(radius: 5))
            }
        }
    }
}

struct MoodIndicatorOverlay: View {
    let mood: Mood
    let confidence: Double
    let energy: Float
    let tempo: Float
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1
    
    var body: some View {
        ZStack {
            // Dynamic mood aura with pulsing animation
            Circle()
                .fill(mood.color.opacity(0.15))
                .scaleEffect(pulseScale)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: pulseScale
                )
            
            VStack(spacing: 8) {
                // Mood icon with dynamic animations
                Image(systemName: mood.systemIcon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(mood.color)
                    .symbolEffect(.bounce, options: .repeating)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Mood label with gradient
                Text(mood.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(mood.color)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(mood.color.opacity(0.1))
                    )
                
                // Feature indicators with dynamic styling
                HStack(spacing: 16) {
                    FeatureIndicator(
                        value: Double(energy),
                        icon: "bolt.fill",
                        label: "Energy",
                        color: mood.color
                    )
                    
                    FeatureIndicator(
                        value: Double(tempo) / 180.0,
                        icon: "metronome",
                        label: "Tempo",
                        color: mood.color
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.95))
                    .shadow(
                        color: mood.color.opacity(0.3),
                        radius: 10,
                        x: 0,
                        y: 4
                    )
            )
        }
        .onAppear {
            isAnimating = true
            pulseScale = 1.2
        }
    }
}

struct FeatureIndicator: View {
    let value: Double
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    
                    // Value indicator with gradient
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.7),
                                    color
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * value)
                        .frame(height: 6)
                }
            }
            .frame(height: 6)
            
            // Percentage indicator
            Text("\(Int(value * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct AudioFeatureRow: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Value bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * value)
                }
            }
            .frame(height: 8)
            .frame(width: 100)
            
            // Percentage
            Text("\(Int(value * 100))%")
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

struct MoodTransitionView: View {
    let currentMood: Mood
    let previousMood: Mood
    let transition: Double
    @State private var progress: CGFloat = 0
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Mood Transition")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                
                Text("\(Int(transition * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 24) {
                // Previous mood indicator
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(previousMood.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: previousMood.systemIcon)
                            .font(.system(size: 20))
                            .foregroundColor(previousMood.color)
                            .opacity(1 - progress)
                    }
                    
                    Text(previousMood.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(previousMood.color)
                        .opacity(1 - progress)
                }
                
                // Transition bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.gray.opacity(0.15))
                        
                        // Transition indicator with dynamic gradient
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        previousMood.color,
                                        currentMood.color
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress)
                            .overlay(
                                // Transition pulse effect
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 12)
                                    .offset(x: geometry.size.width * progress - 6)
                                    .shadow(color: currentMood.color.opacity(0.5), radius: 4)
                            )
                    }
                }
                .frame(height: 8)
                .animation(.spring(response: 0.6), value: progress)
                
                // Current mood indicator
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(currentMood.color.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: currentMood.systemIcon)
                            .font(.system(size: 20))
                            .foregroundColor(currentMood.color)
                            .opacity(progress)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                    }
                    
                    Text(currentMood.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(currentMood.color)
                        .opacity(progress)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                progress = CGFloat(transition)
            }
            
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}