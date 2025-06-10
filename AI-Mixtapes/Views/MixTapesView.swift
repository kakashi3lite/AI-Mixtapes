import SwiftUI

struct MixTapesView: View {
    @StateObject private var viewModel = MixTapesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.mixtapes) { mixtape in
                    NavigationLink(destination: MixtapeDetailView(mixtape: mixtape)) {
                        MixtapeRowView(mixtape: mixtape)
                    }
                }
            }
            .navigationTitle("Your Mixtapes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("By Date", action: { viewModel.sortByDate() })
                        Button("By Mood", action: { viewModel.sortByMood() })
                        Button("By Name", action: { viewModel.sortByName() })
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}

class MixTapesViewModel: ObservableObject {
    @Published var mixtapes: [Mixtape] = []
    
    func sortByDate() {}
    func sortByMood() {}
    func sortByName() {}
}
