import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var aiService: AIIntegrationService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Mixtapes
                    recentMixtapesSection
                    
                    // Mood Insights
                    moodInsightsSection
                }
                .padding()
            }
            .navigationTitle("AI Mixtapes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showNewMixtapeSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showNewMixtapeSheet) {
                NewMixtapeView()
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                QuickActionButton(title: "New Mixtape", icon: "plus.circle.fill", color: .blue) {
                    viewModel.showNewMixtapeSheet = true
                }
                
                QuickActionButton(title: "Analyze Mood", icon: "waveform.path", color: .purple) {
                    viewModel.selectedTab = .mood
                }
                
                QuickActionButton(title: "View Insights", icon: "chart.bar.fill", color: .orange) {
                    viewModel.selectedTab = .insights
                }
                
                QuickActionButton(title: "Browse Library", icon: "music.note.list", color: .green) {
                    viewModel.selectedTab = .mixtapes
                }
            }
        }
    }
    
    private var recentMixtapesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Mixtapes")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.recentMixtapes) { mixtape in
                        MixtapeCard(mixtape: mixtape)
                    }
                }
            }
        }
    }
    
    private var moodInsightsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood Insights")
                .font(.headline)
            
            // Add mood insights visualization here
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - View Model
class HomeViewModel: ObservableObject {
    @Published var showNewMixtapeSheet = false
    @Published var selectedTab: Tab = .home
    @Published var recentMixtapes: [Mixtape] = []
    
    init() {
        // Load recent mixtapes
        loadRecentMixtapes()
    }
    
    private func loadRecentMixtapes() {
        // Implementation for loading recent mixtapes
    }
}

// MARK: - Supporting Views
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
}

struct MixtapeCard: View {
    let mixtape: Mixtape
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "music.note")
                .font(.system(size: 40))
                .padding()
                .frame(width: 120, height: 120)
                .background(Color.secondary.opacity(0.1))
            
            Text(mixtape.name)
                .font(.subheadline)
                .lineLimit(1)
            
            Text(mixtape.mood)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}