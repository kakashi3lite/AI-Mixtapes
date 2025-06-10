import SwiftUI

struct MoodAnalysisView: View {
    @EnvironmentObject var aiService: AIIntegrationService
    @EnvironmentObject var audioProcessor: AudioProcessor
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Audio Visualization
                AudioVisualizationView()
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(15)
                
                // Current Mood Display
                if let currentMood = aiService.currentMood {
                    Text("Current Mood: \(currentMood)")
                        .font(.headline)
                }
                
                // Processing Status
                if aiService.isProcessing {
                    ProgressView("Analyzing...")
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: startMoodAnalysis) {
                        Label("Analyze Mood", systemImage: "waveform.path")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: createMixtape) {
                        Label("Create Mixtape from Mood", systemImage: "music.note.list")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(aiService.currentMood == nil)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Mood Analysis")
        }
    }
    
    private func startMoodAnalysis() {
        Task {
            do {
                _ = try await aiService.analyzeMood(for: AudioBuffer())
            } catch {
                print("Failed to analyze mood: \(error)")
            }
        }
    }
    
    private func createMixtape() {
        // Implementation for creating mixtape from current mood
    }
}