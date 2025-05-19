import SwiftUI

struct AIProcessingView: View {
    let title: String
    let subtitle: String
    @State private var wavePhase = 0.0
    @State private var showingInsight = false
    let insights: [String]
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            // AI Processing Animation
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.accentColor.opacity(0.8), lineWidth: 3)
                        .frame(width: 100 + CGFloat(i * 40), height: 100 + CGFloat(i * 40))
                        .opacity(0.4)
                        .scaleEffect(1 + CGFloat(wavePhase) * 0.1)
                }
                
                Image(systemName: "waveform.path")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                    .symbolEffect(.bounce, options: .repeating)
            }
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: wavePhase)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Text(subtitle)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // AI Insights
            if showingInsight, let insight = insights.randomElement() {
                Text(insight)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .onReceive(timer) { _ in
            wavePhase += 0.05
            
            // Periodically show random insights
            withAnimation {
                showingInsight.toggle()
            }
        }
    }
    
    static let moodAnalysisInsights = [
        "Analyzing tempo and rhythm patterns...",
        "Detecting emotional characteristics...",
        "Processing audio frequencies...",
        "Identifying musical features...",
        "Calculating mood probabilities..."
    ]
    
    static let personalityInsights = [
        "Learning from your preferences...",
        "Analyzing listening patterns...",
        "Building personality profile...",
        "Matching musical traits...",
        "Optimizing recommendations..."
    ]
    
    static let mixtapeCreationInsights = [
        "Curating perfect song combinations...",
        "Optimizing mood transitions...",
        "Balancing musical elements...",
        "Applying AI mixing techniques...",
        "Finalizing playlist order..."
    ]
}
