import SwiftUI

struct MoodHistoryView: View {
    let moodHistory: [MoodEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood History")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(moodHistory) { entry in
                        VStack {
                            Text(entry.mood)
                                .font(.caption)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(moodColor(for: entry.mood))
                                .frame(width: 30, height: entry.intensity * 100)
                            
                            Text(formatDate(entry.timestamp))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func moodColor(for mood: String) -> Color {
        switch mood.lowercased() {
        case "happy": return .yellow
        case "sad": return .blue
        case "energetic": return .red
        case "calm": return .green
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}
