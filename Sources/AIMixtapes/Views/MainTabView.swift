//
//  MainTabView.swift
//  Mixtapes
//
//  Created by Claude AI on 05/16/25.
//  Copyright © 2025 Swanand Tanavade. All rights reserved.
//

import SwiftUI
import AVKit
import CoreData

struct MainTabView: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject private var errorMonitor = CoreDataErrorMonitor()
    
    // Player state
    let queuePlayer: AVQueuePlayer
    let playerItemObserver: PlayerItemObserver
    let playerStatusObserver: PlayerStatusObserver
    @ObservedObject var currentPlayerItems: CurrentPlayerItems
    @ObservedObject var currentSongName: CurrentSongName
    @ObservedObject var isPlaying: IsPlaying
    var aiService: AIIntegrationService
    
    // Navigation and UI state
    @State private var selectedTab = AppSection.library
    @State private var navigationPath = NavigationPath()
    @State private var showMiniPlayer = true
    @State private var showingMoodPicker = false
    @State private var showingPersonalityView = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach([AppSection.library, .generate, .analyze, .insights, .settings], id: \.self) { section in
                    Label(section.title, systemImage: section.icon)
                        .tag(section)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("AI Mixtapes")
        } detail: {
            NavigationStack(path: $navigationPath) {
                Group {
                    switch selectedTab {
                    case .library:
                        LibraryView(aiService: aiService)
                    case .generate: 
                        AIGeneratedMixtapeView(aiService: aiService)
                    case .analyze:
                        AudioVisualizationView(queuePlayer: queuePlayer, 
                                             currentSongName: currentSongName,
                                             aiService: aiService)
                    case .insights:
                        InsightsDashboardView(aiService: aiService)
                    case .settings:
                        SettingsView(aiService: aiService)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button(action: { showingMoodPicker = true }) {
                            Label(aiService.moodEngine.currentMood.rawValue,
                                  systemImage: aiService.moodEngine.currentMood.systemIcon)
                                .foregroundColor(aiService.moodEngine.currentMood.color)
                        }
                        
                        Button(action: { showingPersonalityView = true }) {
                            Label(aiService.personalityEngine.currentPersonality.rawValue,
                                  systemImage: "person.crop.circle")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingMoodPicker) {
            MoodView(moodEngine: aiService.moodEngine)
        }
        .sheet(isPresented: $showingPersonalityView) {
            PersonalityView(personalityEngine: aiService.personalityEngine)
        }
        .overlay(alignment: .bottom) {
            if showMiniPlayer && currentSongName.wrappedValue != "Not Playing" {
                MiniPlayerView(
                    queuePlayer: queuePlayer,
                    currentSongName: currentSongName,
                    isPlaying: isPlaying,
                    aiService: aiService
                )
                .transition(.move(edge: .bottom))
            }
        }
        .tint(aiService.moodEngine.currentMood.color)
    }
}

/// Notification extension for mixtape creation
extension Notification.Name {
    static let mixtapeCreated = Notification.Name("mixtapeCreated")
}

/// Color blending extension
extension Color {
    func blended(with color: Color) -> Color {
        // In a real app, we would implement color blending
        // For now, just return the original color
        return self
    }
}

/// AI suggestion banner that appears periodically
struct AISuggestionBanner: View {
    @Binding var isVisible: Bool
    var aiService: AIIntegrationService
    @Binding var tabSelection: Int
    
    // State
    @State private var suggestion: AISuggestion?
    @State private var dismissTimer: Timer?
    
    var body: some View {
        Group {
            if let suggestion = suggestion {
                VStack {
                    HStack(spacing: 16) {
                        // Icon
                        Image(systemName: suggestion.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(suggestion.color))
                        
                        // Content
                        VStack(alignment: .leading, spacing: 4) {
                            Text(suggestion.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(suggestion.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        // Dismiss button
                        Button(action: {
                            dismissSuggestion()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    
                    // Action button
                    if let action = suggestion.action {
                        Button(action: {
                            executeAction(action)
                        }) {
                            Text(suggestion.actionTitle ?? "Try Now")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(suggestion.color))
                        }
                        .padding(.top, -16)
                        .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            // Generate a suggestion
            generateSuggestion()
            
            // Set up a timer to periodically show suggestions
            setupSuggestionTimer()
        }
        .onDisappear {
            // Cancel timer
            dismissTimer?.invalidate()
        }
    }
    
    /// Generate a context-aware suggestion
    private func generateSuggestion() {
        let currentMood = aiService.moodEngine.currentMood
        let personality = aiService.personalityEngine.currentPersonality
        let timeOfDay = Calendar.current.component(.hour, from: Date())
        
        // Dynamic suggestions based on time and context
        var suggestions: [AISuggestion] = []
        
        // Morning suggestions (6 AM - 12 PM)
        if timeOfDay >= 6 && timeOfDay < 12 {
            suggestions.append(AISuggestion(
                title: "Morning Energy Mix",
                message: "Start your day with an energizing \(currentMood.rawValue) playlist",
                icon: "sunrise.fill",
                color: .orange,
                action: .createMixtape(currentMood),
                actionTitle: "Create Mix"
            ))
        }
        
        // Work hours suggestions (9 AM - 5 PM)
        if timeOfDay >= 9 && timeOfDay < 17 {
            suggestions.append(AISuggestion(
                title: "Focus Enhancement",
                message: "Generate a concentration-boosting playlist based on your work patterns",
                icon: "brain.head.profile",
                color: .blue,
                action: .navigateToTab(1),
                actionTitle: "Enhance Focus"
            ))
        }
        
        // Evening suggestions (5 PM - 11 PM)
        if timeOfDay >= 17 && timeOfDay < 23 {
            suggestions.append(AISuggestion(
                title: "Evening Unwinding",
                message: "Create a relaxing mix to match your evening mood",
                icon: "moon.stars.fill",
                color: .purple,
                action: .createMixtape(.relaxed),
                actionTitle: "Unwind"
            ))
        }
        
        // Personality-based suggestions
        switch personality {
        case .explorer:
            suggestions.append(AISuggestion(
                title: "Discover New Sounds",
                message: "Let AI find fresh tracks that match your adventurous taste",
                icon: "compass.fill",
                color: .green,
                action: .navigateToTab(1),
                actionTitle: "Explore"
            ))
        case .curator:
            suggestions.append(AISuggestion(
                title: "Organize Your Collection",
                message: "Use AI to optimize your playlist organization",
                icon: "square.stack.3d.up.fill",
                color: .indigo,
                action: .navigateToTab(3),
                actionTitle: "Optimize"
            ))
        default:
            suggestions.append(contentsOf: defaultSuggestions(mood: currentMood))
        }
        
        // Pick most relevant suggestion
        self.suggestion = selectMostRelevantSuggestion(from: suggestions)
        aiService.trackInteraction(type: "ai_suggestion_shown")
    }
    
    private func selectMostRelevantSuggestion(from suggestions: [AISuggestion]) -> AISuggestion? {
        // Prioritize suggestions based on user's recent interactions
        // For now, return random but in future could use more sophisticated selection
        return suggestions.randomElement()
    }
    
    private func defaultSuggestions(mood: Mood) -> [AISuggestion] {
        [
            AISuggestion(
                title: "Mood-Matched Mix",
                message: "Create a playlist that matches your \(mood.rawValue.lowercased()) mood",
                icon: mood.systemIcon,
                color: mood.color,
                action: .createMixtape(mood),
                actionTitle: "Create Now"
            )
        ]
    }
    
    /// Set up a timer to periodically show suggestions
    private func setupSuggestionTimer() {
        // Cancel existing timer
        dismissTimer?.invalidate()
        
        // Auto-dismiss after 10 seconds
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            withAnimation {
                isVisible = false
            }
        }
    }
    
    /// Dismiss the current suggestion
    private func dismissSuggestion() {
        withAnimation {
            isVisible = false
        }
        
        // Track dismissal
        aiService.trackInteraction(type: "ai_suggestion_dismissed")
    }
    
    /// Execute a suggestion action
    private func executeAction(_ action: SuggestionAction) {
        switch action {
        case .navigateToTab(let tabIndex):
            tabSelection = tabIndex
            
        case .openSheet(let sheetType):
            // In a real app, we would handle different sheet types
            print("Open sheet: \(sheetType)")
            
        case .createMixtape(let mood):
            // Navigate to generator and set mood
            tabSelection = 1
            
            // In a real app, we would set the mood in the generator
            print("Create mixtape for mood: \(mood.rawValue)")
        }
        
        // Dismiss the suggestion
        dismissSuggestion()
        
        // Track action taken
        aiService.trackInteraction(type: "ai_suggestion_action_taken")
    }
}

/// Model for AI suggestions
struct AISuggestion {
    let title: String
    let message: String
    let icon: String
    let color: Color
    let action: SuggestionAction?
    let actionTitle: String?
}

/// Actions that can be taken from a suggestion
enum SuggestionAction {
    case navigateToTab(Int)
    case openSheet(String)
    case createMixtape(Mood)
}

/// Settings view for configuring AI features
struct SettingsView: View {
    var aiService: AIIntegrationService
    
    // State for settings
    @State private var useAudioAnalysis = true
    @State private var useFacialExpressions = false
    @State private var useSiriIntegration = true
    @State private var showPersonalitySettings = false
    @State private var showMoodSettings = false
    @State private var showSiriSettings = false
    
    var body: some View {
        NavigationView {
            Form {
                // AI Features section
                Section(header: Text("AI Features")) {
                    Toggle("Audio Analysis", isOn: $useAudioAnalysis)
                    Toggle("Facial Expression Detection", isOn: $useFacialExpressions)
                    Toggle("Siri Integration", isOn: $useSiriIntegration)
                }
                
                // Personality section
                Section(header: Text("Personality Profile")) {
                    Button(action: {
                        showPersonalitySettings = true
                    }) {
                        HStack {
                            Text("Your Music Personality")
                            Spacer()
                            Text(aiService.personalityEngine.currentPersonality.rawValue)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $showPersonalitySettings) {
                        PersonalityView(personalityEngine: aiService.personalityEngine)
                    }
                }
                
                // Mood section
                Section(header: Text("Mood Settings")) {
                    Button(action: {
                        showMoodSettings = true
                    }) {
                        HStack {
                            Text("Current Mood")
                            Spacer()
                            Text(aiService.moodEngine.currentMood.rawValue)
                                .foregroundColor(aiService.moodEngine.currentMood.color)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $showMoodSettings) {
                        MoodView(moodEngine: aiService.moodEngine)
                    }
                }
                
                // Siri section
                Section(header: Text("Siri Integration")) {
                    Button(action: {
                        showSiriSettings = true
                    }) {
                        HStack {
                            Text("Manage Siri Shortcuts")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $showSiriSettings) {
                        SiriShortcutsView(aiService: aiService)
                    }
                }
                
                // About section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Swanand Tanavade")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .large)
            .onChange(of: useAudioAnalysis) { newValue in
                // Track setting change
                aiService.trackInteraction(type: "setting_audio_analysis_\(newValue ? "enabled" : "disabled")")
            }
            .onChange(of: useFacialExpressions) { newValue in
                // Track setting change
                aiService.trackInteraction(type: "setting_facial_expressions_\(newValue ? "enabled" : "disabled")")
            }
            .onChange(of: useSiriIntegration) { newValue in
                // Track setting change
                aiService.trackInteraction(type: "setting_siri_integration_\(newValue ? "enabled" : "disabled")")
            }
        }
    }
}
