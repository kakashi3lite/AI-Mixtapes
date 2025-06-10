import SwiftUI

struct MixTapeView: View {
    @StateObject private var viewModel = MixTapeViewModel()
    @EnvironmentObject var aiService: AIIntegrationService
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.mixtapes) { mixtape in
                    NavigationLink(destination: MixtapeDetailView(mixtape: mixtape)) {
                        MixtapeRow(mixtape: mixtape)
                    }
                }
                .onDelete(perform: viewModel.deleteMixtape)
            }
            .navigationTitle("Your Mixtapes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("By Date") { viewModel.sortByDate() }
                        Button("By Mood") { viewModel.sortByMood() }
                        Button("By Name") { viewModel.sortByName() }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .refreshable {
                await viewModel.loadMixtapes()
            }
        }
    }
}

struct MixtapeRow: View {
    let mixtape: Mixtape
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "music.note")
                    .font(.title)
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mixtape.name)
                    .font(.headline)
                
                Text("Mood: \(mixtape.mood)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(mixtape.songs.count) songs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

class MixTapeViewModel: ObservableObject {
    @Published var mixtapes: [Mixtape] = []
    
    func loadMixtapes() async {
        // Implementation for loading mixtapes
    }
    
    func deleteMixtape(at offsets: IndexSet) {
        mixtapes.remove(atOffsets: offsets)
        // Implementation for deleting mixtapes
    }
    
    func sortByDate() {
        mixtapes.sort { $0.createdAt > $1.createdAt }
    }
    
    func sortByMood() {
        mixtapes.sort { $0.mood < $1.mood }
    }
    
    func sortByName() {
        mixtapes.sort { $0.name < $1.name }
    }
}