import UIKit

class PlaceholderImageGenerator {
    static func generateMoodImage(for mood: Mood, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            let backgroundColor = moodColor(for: mood)
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Symbol configuration
            let config = UIImage.SymbolConfiguration(pointSize: size.width * 0.4, weight: .medium)
            let symbolName = moodSymbol(for: mood)
            
            if let symbol = UIImage(systemName: symbolName, withConfiguration: config) {
                // Draw symbol in white
                let symbolRect = CGRect(
                    x: (size.width - symbol.size.width) / 2,
                    y: (size.height - symbol.size.height) / 2,
                    width: symbol.size.width,
                    height: symbol.size.height
                )
                
                symbol.withTintColor(.white, renderingMode: .alwaysTemplate)
                    .draw(in: symbolRect)
            }
            
            // Add subtle pattern overlay
            drawPatternOverlay(in: context.cgContext, size: size, mood: mood)
        }
    }
    
    private static func moodColor(for mood: Mood) -> UIColor {
        switch mood {
        case .energetic: return .systemRed
        case .relaxed: return .systemBlue
        case .happy: return .systemYellow
        case .melancholic: return .systemPurple
        case .focused: return .systemGreen
        case .romantic: return .systemPink
        case .angry: return .systemOrange
        case .neutral: return .systemGray
        }
    }
    
    private static func moodSymbol(for mood: Mood) -> String {
        switch mood {
        case .energetic: return "bolt.fill"
        case .relaxed: return "cloud.fill"
        case .happy: return "sun.max.fill"
        case .melancholic: return "moon.fill"
        case .focused: return "target"
        case .romantic: return "heart.fill"
        case .angry: return "flame.fill"
        case .neutral: return "circle.fill"
        }
    }
    
    private static func drawPatternOverlay(in context: CGContext, size: CGSize, mood: Mood) {
        context.saveGState()
        
        // Set blend mode and opacity for overlay
        context.setBlendMode(.overlay)
        context.setAlpha(0.1)
        
        // Create pattern based on mood
        switch mood {
        case .energetic:
            drawZigzagPattern(in: context, size: size)
        case .relaxed:
            drawWavePattern(in: context, size: size)
        case .happy:
            drawSunburstPattern(in: context, size: size)
        case .melancholic:
            drawRainPattern(in: context, size: size)
        case .focused:
            drawCircularPattern(in: context, size: size)
        case .romantic:
            drawHeartPattern(in: context, size: size)
        case .angry:
            drawSpikePattern(in: context, size: size)
        case .neutral:
            drawGridPattern(in: context, size: size)
        }
        
        context.restoreGState()
    }
    
    // Pattern drawing methods
    private static func drawZigzagPattern(in context: CGContext, size: CGSize) {
        let path = UIBezierPath()
        let step = size.width / 20
        
        for x in stride(from: 0, to: size.width + step, by: step) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + step, y: size.height))
        }
        
        UIColor.white.setStroke()
        path.lineWidth = 1
        path.stroke()
    }
    
    // Add similar methods for other patterns...
    
    // Utility method to generate all mood placeholder images
    static func generateAllMoodImages() {
        let size = CGSize(width: 512, height: 512)
        let fileManager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        for mood in Mood.allCases {
            let image = generateMoodImage(for: mood, size: size)
            let filename = "mood-\(mood.rawValue).png"
            let filepath = (documentsPath as NSString).appendingPathComponent(filename)
            
            if let data = image.pngData() {
                try? data.write(to: URL(fileURLWithPath: filepath))
            }
        }
    }
}
