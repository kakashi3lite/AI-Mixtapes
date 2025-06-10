import SwiftUI

struct AudioControlsView: View {
    @Binding var isPlaying: Bool
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 180 // Example duration
    
    var body: some View {
        VStack(spacing: 15) {
            // Progress Bar
            ProgressView(value: currentTime, total: duration)
                .padding(.horizontal)
            
            // Time Labels
            HStack {
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(duration))
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            
            // Control Buttons
            HStack(spacing: 40) {
                Button(action: previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }
                
                Button(action: nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func togglePlayPause() {
        isPlaying.toggle()
    }
    
    private func previousTrack() {}
    private func nextTrack() {}
}
