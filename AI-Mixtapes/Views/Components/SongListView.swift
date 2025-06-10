import SwiftUI

struct SongListView: View {
    let songs: [Song]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(songs) { song in
                SongRowView(song: song)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                
                if song.id != songs.last?.id {
                    Divider()
                        .padding(.leading)
                }
            }
        }
    }
}

struct SongRowView: View {
    let song: Song
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.system(.body, design: .rounded))
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatDuration(song.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
