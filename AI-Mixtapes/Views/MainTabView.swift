import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            MixTapesView()
                .tabItem {
                    Label("Mixtapes", systemImage: "music.note.list")
                }
            
            MoodAnalysisView()
                .tabItem {
                    Label("Mood", systemImage: "waveform.path")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
