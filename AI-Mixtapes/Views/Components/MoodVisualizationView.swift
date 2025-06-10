import SwiftUI

struct MoodVisualizationView: View {
    let currentMood: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Current Mood")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.accentColor, lineWidth: 20)
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Image(systemName: moodIcon)
                        .font(.system(size: 40))
                    Text(currentMood)
                        .font(.title2)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(15)
    }
    
    var moodIcon: String {
        switch currentMood.lowercased() {
        case "happy": return "sun.max.fill"
        case "sad": return "cloud.rain.fill"
        case "energetic": return "bolt.fill"
        case "calm": return "moon.stars.fill"
        default: return "waveform"
        }
    }
}
