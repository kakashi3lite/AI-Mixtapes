import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    QuickActionsView()
                    
                    // Recent Mixtapes
                    RecentMixtapesView()
                    
                    // Mood Suggestions
                    MoodSuggestionsView()
                }
                .padding()
            }
            .navigationTitle("AI Mixtapes")
            .toolbar {
                Button(action: { viewModel.createNewMixtape() }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

class HomeViewModel: ObservableObject {
    func createNewMixtape() {
        // Implementation for creating new mixtape
    }
}
