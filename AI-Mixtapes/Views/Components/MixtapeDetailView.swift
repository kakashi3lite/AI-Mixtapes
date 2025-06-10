import SwiftUI

struct MixtapeDetailView: View {
    let mixtape: Mixtape
    @StateObject private var viewModel = MixtapeDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Cover Art
                CoverArtView(coverArt: mixtape.coverArt)
                    .frame(height: 200)
                
                // Mixtape Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(mixtape.name)
                        .font(.title)
                        .bold()
                    
                    Text("Mood: \(mixtape.mood)")
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatDuration(mixtape.duration))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Song List
                SongListView(songs: mixtape.songs)
                
                // Audio Controls
                AudioControlsView(isPlaying: $viewModel.isPlaying)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Share", action: viewModel.shareMixtape)
                    Button("Edit", action: viewModel.editMixtape)
                    Button("Delete", action: viewModel.deleteMixtape)
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

class MixtapeDetailViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
    
    func shareMixtape() {}
    func editMixtape() {}
    func deleteMixtape() {}
}
