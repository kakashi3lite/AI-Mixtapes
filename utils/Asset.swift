import UIKit
import SwiftUI

/// Provides type-safe access to app assets
enum Asset {
    /// App images
    enum Image: String {
        case launchIcon = "LaunchIcon"
        
        /// Get a UIImage for this asset
        var uiImage: UIKit.UIImage {
            guard let image = UIKit.UIImage(named: rawValue) else {
                fatalError("Missing asset: \(rawValue)")
            }
            return image
        }
        
        /// Get a SwiftUI Image for this asset
        var image: SwiftUI.Image {
            SwiftUI.Image(rawValue)
        }
    }
    
    /// App colors
    enum Color: String {
        case appPrimary
        case appSecondary
        case background
        
        /// Get a UIColor for this asset
        var uiColor: UIKit.UIColor {
            guard let color = UIKit.UIColor(named: rawValue) else {
                fatalError("Missing color asset: \(rawValue)")
            }
            return color
        }
        
        /// Get a SwiftUI Color for this asset
        var color: SwiftUI.Color {
            SwiftUI.Color(rawValue)
        }
    }
    
    /// Mood-based colors
    enum MoodColor: String, CaseIterable {
        case angry = "Angry"
        case energetic = "Energetic"
        case focused = "Focused"
        case happy = "Happy"
        case melancholic = "Melancholic"
        case relaxed = "Relaxed"
        
        /// Get a UIColor for this mood
        var uiColor: UIKit.UIColor {
            guard let color = UIKit.UIColor(named: "Mood/\(rawValue)") else {
                fatalError("Missing mood color asset: \(rawValue)")
            }
            return color
        }
        
        /// Get a SwiftUI Color for this mood
        var color: SwiftUI.Color {
            SwiftUI.Color("Mood/\(rawValue)")
        }
        
        /// Get color with specified opacity
        func withOpacity(_ opacity: Double) -> SwiftUI.Color {
            color.opacity(opacity)
        }
    }
    
    /// Personality-based colors
    enum PersonalityColor: String, CaseIterable {
        case curator = "Curator"
        case enthusiast = "Enthusiast"
        case explorer = "Explorer"
        
        /// Get a UIColor for this personality
        var uiColor: UIKit.UIColor {
            guard let color = UIKit.UIColor(named: "Personality/\(rawValue)") else {
                fatalError("Missing personality color asset: \(rawValue)")
            }
            return color
        }
        
        /// Get a SwiftUI Color for this personality
        var color: SwiftUI.Color {
            SwiftUI.Color("Personality/\(rawValue)")
        }
        
        /// Get color with specified opacity
        func withOpacity(_ opacity: Double) -> SwiftUI.Color {
            color.opacity(opacity)
        }
    }
    
    /// Get a UIImage by name with validation
    static func image(name: String) -> UIKit.UIImage {
        guard let image = UIKit.UIImage(named: name) else {
            fatalError("Missing image asset: \(name)")
        }
        return image
    }
    
    /// Get a UIColor by name with validation
    static func color(name: String) -> UIKit.UIColor {
        guard let color = UIKit.UIColor(named: name) else {
            fatalError("Missing color asset: \(name)")
        }
        return color
    }
}