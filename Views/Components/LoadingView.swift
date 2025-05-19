import SwiftUI

struct LoadingView: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.accentColor, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    let total: Double
    let message: String
    
    var percentage: Double {
        min(max(progress / total, 0), 1)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .cornerRadius(5)
                    
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * CGFloat(percentage))
                        .cornerRadius(5)
                        .animation(.easeInOut, value: percentage)
                }
            }
            .frame(height: 10)
            
            Text("\(Int(percentage * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    var actionOptions = Set<AsyncButton.Options>()
    @ViewBuilder let label: () -> Label
    
    @State private var isRunning = false
    @State private var error: Error?
    
    var body: some View {
        Button(
            action: {
                isRunning = true
                error = nil
                
                Task {
                    do {
                        try await action()
                    } catch {
                        self.error = error
                    }
                    isRunning = false
                }
            },
            label: {
                ZStack {
                    label()
                        .opacity(isRunning ? 0 : 1)
                    
                    if isRunning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            }
        )
        .disabled(isRunning)
        .alert(
            "Error",
            isPresented: .constant(error != nil),
            actions: {
                Button("OK") {
                    error = nil
                }
            },
            message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
        )
    }
    
    enum Options {
        case disableButton
        case showProgressView
    }
}
