import SwiftUI

struct FullscreenMoodView: View {
    let mood: Mood
    let confidence: Double
    @Environment(\.dismiss) var dismiss
    @State private var phase: CGFloat = 0
    @State private var isAnimating = false
    @State private var showDetails = false
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Animated background
            GeometryReader { geometry in
                ForEach(0..<5) { i in
                    WaveShape(phase: phase + Double(i) * .pi / 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    mood.color.opacity(0.1 + Double(i) * 0.05),
                                    mood.color.opacity(0.2 + Double(i) * 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(1 + CGFloat(i) * 0.1)
                        .offset(y: CGFloat(i) * 20)
                }
            }
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 32) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Mood visualization
                VStack(spacing: 24) {
                    // Mood icon with animations
                    ZStack {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(mood.color.opacity(0.3 - Double(i) * 0.1), lineWidth: 1)
                                .frame(width: 120 + CGFloat(i) * 40, height: 120 + CGFloat(i) * 40)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.3),
                                    value: isAnimating
                                )
                        }
                        
                        Image(systemName: mood.systemIcon)
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .symbolEffect(.bounce, options: .repeating)
                    }
                    
                    // Mood name with animation
                    Text(mood.rawValue.uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(showDetails ? 1 : 0)
                        .offset(y: showDetails ? 0 : 20)
                    
                    // Confidence meter
                    VStack(spacing: 8) {
                        GeometryReader { metrics in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 12)
                                
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: metrics.size.width * confidence)
                                    .frame(height: 12)
                            }
                        }
                        .frame(height: 12)
                        .opacity(showDetails ? 1 : 0)
                        
                        Text("\(Int(confidence * 100))% Confidence")
                            .font(.title3)
                            .foregroundColor(.white)
                            .opacity(showDetails ? 1 : 0)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Mood description
                if showDetails {
                    Text(getMoodDescription(mood))
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(mood.color.opacity(0.8))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showDetails = true
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.05)) {
                phase += 0.05
            }
        }
    }
    
    private func getMoodDescription(_ mood: Mood) -> String {
        switch mood {
        case .energetic:
            return "High-energy music with upbeat rhythms and dynamic patterns. Perfect for workouts, parties, or when you need a boost of energy."
        case .relaxed:
            return "Calming melodies and gentle harmonies that help you unwind and find peace. Ideal for meditation, reading, or winding down."
        case .happy:
            return "Uplifting tunes that spread joy and positivity. Great for brightening your day or celebrating good moments."
        case .melancholic:
            return "Emotional and reflective music that resonates with deeper feelings. Helps process emotions or find solace in contemplative moments."
        case .focused:
            return "Balanced and steady compositions that enhance concentration. Perfect for work, study, or any task requiring mental clarity."
        case .romantic:
            return "Tender and intimate melodies that express love and connection. Sets the mood for special moments with loved ones."
        case .angry:
            return "Intense and powerful tracks that channel strong emotions. Helps release tension or fuel high-intensity activities."
        case .neutral:
            return "Balanced and versatile music that adapts to any mood. A perfect middle ground when you want pleasant background accompaniment."
        }
    }
}
