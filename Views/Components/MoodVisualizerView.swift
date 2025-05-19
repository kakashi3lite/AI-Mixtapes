import SwiftUI

struct MoodVisualizerView: View {
    let mood: Mood
    let confidence: Double
    @State private var wavePhase: CGFloat = 0
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1
    @State private var showingFullscreen = false
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic mood aura
                Circle()
                    .fill(mood.color.opacity(0.1))
                    .scaleEffect(pulseScale)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: pulseScale
                    )
                
                // Background waves with varying opacity and phase
                ForEach(0..<3) { i in
                    WaveShape(phase: wavePhase + Double(i) * .pi / 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    mood.color.opacity(0.1 + Double(i) * 0.1),
                                    mood.color.opacity(0.2 + Double(i) * 0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(1 + CGFloat(i) * 0.1)
                }
                
                // Mood indicator
                VStack(spacing: 16) {
                    // Mood icon with pulsing animation
                    Image(systemName: mood.systemIcon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(mood.color)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // Confidence meter with gradient
                    VStack(spacing: 4) {
                        Text("\(Int(confidence * 100))% Confidence")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { metrics in
                            ZStack(alignment: .leading) {
                                // Background track
                                Capsule()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 8)
                                
                                // Confidence indicator with gradient
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                mood.color.opacity(0.8),
                                                mood.color
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: metrics.size.width * CGFloat(confidence))
                                    .frame(height: 8)
                            }
                        }
                        .frame(height: 8)
                        .animation(.spring(response: 0.5), value: confidence)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: mood.color.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding()
                
                // Make the whole view tappable
                Button(action: {
                    showingFullscreen = true
                }) {
                    Color.clear
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingFullscreen) {
            FullscreenMoodView(
                mood: mood,
                confidence: confidence
            )
        }
        .onAppear {
            isAnimating = true
            pulseScale = 1.2
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.05)) {
                wavePhase += 0.05
            }
        }
    }
}

struct WaveShape: Shape {
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let y = sin(relativeX * 2 * .pi + phase) * 20 + midHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}
