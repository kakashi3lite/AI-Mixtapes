import SwiftUI

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 15) {
                QuickActionButton(title: "New Mixtape", icon: "plus.circle.fill", action: {})
                QuickActionButton(title: "Analyze Mood", icon: "waveform.path", action: {})
                QuickActionButton(title: "Discover", icon: "sparkles", action: {})
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.caption)
            }
            .frame(width: 100, height: 100)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(12)
        }
    }
}
