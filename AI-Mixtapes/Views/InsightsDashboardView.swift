import SwiftUI
import Charts

struct InsightsDashboardView: View {
    @StateObject private var viewModel = InsightsDashboardViewModel()
    @EnvironmentObject var aiService: AIIntegrationService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Mood Distribution Chart
                    moodDistributionCard
                    
                    // Listening Patterns
                    listeningPatternsCard
                    
                    // Top Genres
                    topGenresCard
                    
                    // Recent Activity
                    recentActivityCard
                }
                .padding()
            }
            .navigationTitle("Insights")
            .refreshable {
                await viewModel.loadInsights()
            }
        }
    }
    
    private var moodDistributionCard: some View {
        InsightCard(title: "Mood Distribution") {
            if #available(iOS 16.0, *) {
                Chart(viewModel.moodData) { mood in
                    BarMark(
                        x: .value("Mood", mood.name),
                        y: .value("Count", mood.count)
                    )
                    .foregroundStyle(by: .value("Mood", mood.name))
                }
                .frame(height: 200)
            } else {
                // Fallback for iOS 15
                Text("Mood distribution visualization")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var listeningPatternsCard: some View {
        InsightCard(title: "Listening Patterns") {
            if #available(iOS 16.0, *) {
                Chart(viewModel.listeningData) { data in
                    LineMark(
                        x: .value("Time", data.hour),
                        y: .value("Plays", data.plays)
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
            } else {
                Text("Listening patterns visualization")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var topGenresCard: some View {
        InsightCard(title: "Top Genres") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.topGenres, id: \.name) { genre in
                    HStack {
                        Text(genre.name)
                        Spacer()
                        Text("\(genre.percentage, specifier: "%.0f")%")
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: genre.percentage, total: 100)
                        .tint(.accentColor)
                }
            }
        }
    }
    
    private var recentActivityCard: some View {
        InsightCard(title: "Recent Activity") {
            ForEach(viewModel.recentActivity) { activity in
                HStack {
                    Image(systemName: activity.icon)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text(activity.title)
                            .font(.subheadline)
                        Text(activity.timestamp)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                
                if activity.id != viewModel.recentActivity.last?.id {
                    Divider()
                }
            }
        }
    }
}

struct InsightCard<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            content()
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(15)
    }
}

class InsightsDashboardViewModel: ObservableObject {
    @Published var moodData: [MoodData] = []
    @Published var listeningData: [ListeningData] = []
    @Published var topGenres: [GenreData] = []
    @Published var recentActivity: [ActivityData] = []
    
    func loadInsights() async {
        // Implementation for loading insights data
    }
}

// MARK: - Data Models
struct MoodData: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}

struct ListeningData: Identifiable {
    let id = UUID()
    let hour: Int
    let plays: Int
}

struct GenreData {
    let name: String
    let percentage: Double
}

struct ActivityData: Identifiable {
    let id = UUID()
    let title: String
    let timestamp: String
    let icon: String
}