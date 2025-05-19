import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showingMoodDemo = false
    @State private var demoMood: Mood = .happy
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to AI Mixtapes",
            description: "Create personalized playlists powered by artificial intelligence that match your mood and personality.",
            imageName: "wand.and.stars",
            backgroundColor: .blue
        ),
        OnboardingPage(
            title: "Mood Detection",
            description: "Our advanced audio analysis detects the mood of your music and creates perfectly balanced playlists.",
            imageName: "heart.fill",
            backgroundColor: .purple
        ),
        OnboardingPage(
            title: "Smart Recommendations",
            description: "Get intelligent music suggestions based on your listening habits and preferences.",
            imageName: "brain.head.profile",
            backgroundColor: .green
        ),
        OnboardingPage(
            title: "Voice Control",
            description: "Use Siri to control your mixtapes and create new ones hands-free.",
            imageName: "waveform",
            backgroundColor: .orange
        ),
        OnboardingPage(
            title: "AI-Powered Mood Detection",
            description: "Experience real-time mood analysis of your music through advanced audio processing.",
            imageName: "waveform.path",
            backgroundColor: .blue,
            demoType: .moodDetection
        ),
        OnboardingPage(
            title: "Personality-Driven Playlists",
            description: "Our AI learns your music personality to create the perfect mixtapes for every moment.",
            imageName: "person.2.circle.fill",
            backgroundColor: .purple,
            demoType: .personality
        ),
        OnboardingPage(
            title: "Smart Audio Analysis",
            description: "Visualize the musical characteristics that make your favorite songs special.",
            imageName: "chart.bar.xaxis",
            backgroundColor: .green,
            demoType: .audioAnalysis
        ),
        OnboardingPage(
            title: "Voice Commands",
            description: "Just tell Siri what mood you're in, and let AI create the perfect mixtape.",
            imageName: "mic.circle.fill",
            backgroundColor: .orange,
            demoType: .voiceControl
        ),
        OnboardingPage(
            title: "Personalized Insights",
            description: "Get AI-powered insights about your music preferences and listening patterns.",
            imageName: "brain.head.profile",
            backgroundColor: .indigo,
            demoType: .insights
        )
    ]
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(
                        page: pages[index],
                        showDemo: $showingMoodDemo,
                        demoMood: $demoMood
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            VStack {
                Spacer()
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(.white.opacity(0.3))
                            .frame(height: 4)
                        
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width * CGFloat(currentPage + 1) / CGFloat(pages.count), height: 4)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal)
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(currentPage < pages.count - 1 ? "Next" : "Get Started") {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingMoodDemo) {
            MoodDemoView(mood: $demoMood)
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
    let demoType: OnboardingDemoType
}

enum OnboardingDemoType {
    case moodDetection
    case personality
    case audioAnalysis
    case voiceControl
    case insights
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    @Binding var showDemo: Bool
    @Binding var demoMood: Mood
    
    var body: some View {
        ZStack {
            page.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isAnimating)
                
                Text(page.title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: isAnimating)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: isAnimating)
                
                Spacer()
                
                // Demo button for AI-focused pages
                if page.demoType != nil {
                    Button(action: {
                        showDemo = true
                    }) {
                        Text("Try Demo")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct MoodDemoView: View {
    @Binding var mood: Mood
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Try Out Mood Detection")
                    .font(.title2)
                    .bold()
                
                Picker("Select a mood", selection: $mood) {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Text(mood.rawValue.capitalized)
                            .tag(mood)
                    }
                }
                .pickerStyle(.wheel)
                
                AudioVisualizationPreview(mood: mood)
                    .frame(height: 200)
                    .padding()
                
                Text("In the app, our AI automatically detects the mood of your music in real-time!")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Got it!") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationBarTitle("Mood Detection Demo", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}
