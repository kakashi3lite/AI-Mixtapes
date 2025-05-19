import SwiftUI
import AVKit

struct SongRowView: View {
    @ObservedObject var song: Song
    @State private var isPlaying = false
    @State private var progress: Double = 0
    
    private let audioFileManager = AudioFileManager()
    
    var body: some View {
        HStack {
            // Play/Pause Button
            Button(action: {
                isPlaying.toggle()
                if isPlaying {
                    playSong()
                } else {
                    pauseSong()
                }
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Song Info
            VStack(alignment: .leading) {
                Text(song.wrappedTitle)
                    .font(.body)
                    .lineLimit(1)
                
                Text(song.wrappedArtist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Duration
            Text(song.formattedDuration)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .onReceive(NotificationCenter.default.publisher(for: .playAudio)) { notification in
            if let userInfo = notification.userInfo,
               let url = userInfo["url"] as? URL,
               url == song.url {
                isPlaying = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .pauseAudio)) { notification in
            if let userInfo = notification.userInfo,
               let url = userInfo["url"] as? URL,
               url == song.url {
                isPlaying = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateProgress)) { notification in
            if let userInfo = notification.userInfo,
               let url = userInfo["url"] as? URL,
               let currentProgress = userInfo["progress"] as? Double,
               url == song.url {
                progress = currentProgress
            }
        }
    }
    
    private func playSong() {
        guard let url = song.url else { return }
        
        audioFileManager.cacheAudioFile(from: url) { result in
            switch result {
            case .success(let localURL):
                NotificationCenter.default.post(
                    name: .playAudio,
                    object: nil,
                    userInfo: [
                        "url": localURL,
                        "title": song.wrappedTitle,
                        "artist": song.wrappedArtist
                    ]
                )
            case .failure(let error):
                print("Failed to play song: \(error)")
            }
        }
    }
    
    private func pauseSong() {
        guard let url = song.url else { return }
        NotificationCenter.default.post(
            name: .pauseAudio,
            object: nil,
            userInfo: ["url": url]
        )
    }
}
