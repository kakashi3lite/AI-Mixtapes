import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = MainTabViewModel()
    @EnvironmentObject var aiService: AIIntegrationService
    @EnvironmentObject var audioProcessor: AudioProcessor
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            MixTapeView()
                .tabItem {
                    Label("Mixtapes", systemImage: "music.note.list")
                }
                .tag(Tab.mixtapes)
            
            MoodAnalysisView()
                .tabItem {
                    Label("Mood", systemImage: "waveform.path")
                }
                .tag(Tab.mood)
            
            InsightsDashboardView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(Tab.insights)
        }
        .onChange(of: viewModel.selectedTab) { newTab in
            viewModel.handleTabChange(newTab, audioProcessor: audioProcessor)
        }
    }
}

class MainTabViewModel: ObservableObject {
    @Published var selectedTab: Tab = .home
    
    func handleTabChange(_ tab: Tab, audioProcessor: AudioProcessor) {
        switch tab {
        case .mood:
            audioProcessor.startProcessing()
        case .home, .mixtapes, .insights:
            audioProcessor.stopProcessing()
        }
    }
}

enum Tab {
    case home
    case mixtapes
    case mood
    case insights
}