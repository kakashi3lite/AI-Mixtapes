# UI Components Documentation

## Navigation Structure
The app uses a tab-based navigation with four main sections:
- Home: Quick actions and recent mixtapes
- Mixtapes: Library management and playlist creation
- Mood Analysis: Real-time audio processing and mood detection
- Insights: Analytics and listening patterns

## Core Components

### AudioVisualizationView
Real-time waveform visualization for audio processing. Automatically starts/stops based on the selected tab.

### MoodAnalysisView
Provides real-time mood analysis with:
- Live audio visualization
- Current mood display
- Historical mood tracking
- Mixtape generation based on mood

### InsightsDashboardView
Data visualization components including:
- Mood distribution charts
- Listening pattern analysis
- Top genres breakdown
- Recent activity tracking

### MixTapeView
Playlist management interface with:
- Sorting options (date, mood, name)
- Detailed playlist view
- Playback controls
- Mood-based recommendations

## State Management
- Uses ObservableObject for view models
- EnvironmentObject for global services (AIIntegrationService, AudioProcessor)
- Automatic audio processing lifecycle management

## Dependencies
- AudioKit: Audio processing and analysis
- OpenAI: Mood analysis and recommendations
- SwiftUI Charts: Data visualization (iOS 16+)

## Usage Guidelines
1. Audio processing automatically starts in MoodAnalysisView
2. Use QuickActionButton for common actions
3. Implement error handling using provided ErrorView
4. Follow mood-based theming guidelines