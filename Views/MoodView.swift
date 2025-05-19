//
//  MoodView.swift
//  Mixtapes
//
//  Created by Claude AI on 05/16/25.
//  Copyright © 2025 Swanand Tanavade. All rights reserved.
//

import SwiftUI

/// View for selecting and displaying the current mood
struct MoodView: View {
    @ObservedObject var moodEngine: MoodEngine
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMood: Mood?
    @State private var isAnalyzing = false
    @State private var showingTutorial = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current mood visualization
                    VStack(spacing: 16) {
                        Text("Current Mood")
                            .font(.title2)
                            .bold()
                        
                        MoodVisualizerView(
                            mood: moodEngine.currentMood,
                            confidence: moodEngine.moodConfidence
                        )
                        .frame(height: 200)
                        
                        // Mood description
                        Text(moodEngine.currentMood.description)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    // Mood analysis status
                    if isAnalyzing {
                        AIProcessingView(
                            title: "Analyzing Audio",
                            subtitle: "Detecting musical characteristics and emotional patterns",
                            insights: [
                                "Analyzing tempo and rhythm...",
                                "Processing harmonic content...",
                                "Detecting emotional patterns...",
                                "Calculating mood probabilities...",
                                "Finalizing mood analysis..."
                            ]
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Mood selection grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            MoodSelectionCard(
                                mood: mood,
                                isSelected: selectedMood == mood,
                                confidence: moodEngine.confidenceFor(mood: mood)
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedMood = mood
                                    updateMood(to: mood)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Mood Detection", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Tutorial") {
                    showingTutorial = true
                },
                trailing: Button("Done") {
                    dismiss()
                }
            )
            .sheet(isPresented: $showingTutorial) {
                MoodTutorialView()
            }
        }
    }
    
    private func updateMood(to mood: Mood) {
        withAnimation {
            isAnalyzing = true
        }
        
        // Simulate mood analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                moodEngine.setMood(mood, confidence: Double.random(in: 0.7...0.95))
                isAnalyzing = false
            }
        }
    }
}

struct MoodSelectionCard: View {
    let mood: Mood
    let isSelected: Bool
    let confidence: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Mood icon
            Image(systemName: mood.systemIcon)
                .font(.system(size: 32))
                .foregroundColor(isSelected ? .white : mood.color)
            
            // Mood name
            Text(mood.rawValue.capitalized)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
            
            // Confidence bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(isSelected ? .white : mood.color)
                        .frame(width: geometry.size.width * confidence)
                        .frame(height: 4)
                }
            }
            .frame(height: 4)
            
            // Confidence percentage
            Text("\(Int(confidence * 100))%")
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? mood.color : Color(UIColor.systemBackground))
                .shadow(color: mood.color.opacity(isSelected ? 0.5 : 0.2),
                       radius: isSelected ? 10 : 5)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct MoodTutorialView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Tutorial sections
                    TutorialSection(
                        title: "Real-time Mood Detection",
                        description: "Our AI analyzes audio in real-time to detect the emotional characteristics of your music.",
                        imageName: "waveform.path"
                    )
                    
                    TutorialSection(
                        title: "Multiple Features",
                        description: "We analyze tempo, harmony, rhythm, and many other musical features to determine mood.",
                        imageName: "music.note.list"
                    )
                    
                    TutorialSection(
                        title: "Confidence Levels",
                        description: "See how confident our AI is about each mood detection, ensuring accuracy and transparency.",
                        imageName: "gauge.medium"
                    )
                    
                    TutorialSection(
                        title: "Personalized Learning",
                        description: "The more you use the app, the better it gets at understanding your musical preferences.",
                        imageName: "person.fill.checkmark"
                    )
                    
                    Button("Got it!") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            }
            .navigationBarTitle("How Mood Detection Works", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

struct TutorialSection: View {
    let title: String
    let description: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: imageName)
                .font(.system(size: 44))
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}
