# Anchor Architecture

## Overview

Anchor is built with a modular architecture that separates concerns and enables easy testing and maintenance.

## Project Structure

```
Anchor/
├── AnchorApp.swift          # App entry point
├── ContentView.swift        # Main UI view
├── Models/                  # Data models
│   ├── AppState.swift       # Global app state
│   ├── StressLevel.swift    # Stress level enum
│   └── Session.swift        # Session extensions
├── Services/                # Business logic & API integrations
│   ├── Config.swift         # API configuration
│   ├── PresageService.swift # Presage API integration
│   ├── StressMonitor.swift  # Stress level monitoring
│   ├── GeminiService.swift  # Google Gemini integration
│   ├── ElevenLabsService.swift # TTS/STT integration
│   ├── PersonalizationService.swift # Gradient AI integration
│   ├── SolanaService.swift  # Blockchain integration
│   ├── ConversationManager.swift # Conversation orchestration
│   └── WatchConnectivityService.swift # Watch communication
├── Views/                   # SwiftUI views
│   ├── StressIndicatorView.swift
│   ├── CameraPreviewView.swift
│   ├── ConversationView.swift
│   ├── VoiceControlView.swift
│   └── SessionSummaryView.swift
└── Extensions/
    └── Color+Hex.swift      # Color utilities

AnchorWatch/
├── AnchorWatchApp.swift     # Watch app entry
├── ContentView.swift        # Watch UI
└── HeartRateMonitor.swift   # Heart rate monitoring
```

## Data Flow

### Stress Detection Flow
1. **Apple Watch** → Detects heart rate spike → Sends alert
2. **iPhone App** → Opens → Starts camera capture
3. **PresageService** → Analyzes frames → Returns stress readings
4. **StressMonitor** → Processes readings → Updates stress level
5. **ConversationManager** → Adapts conversation based on level

### Conversation Flow
1. **User** → Sends message (text/voice)
2. **PersonalizationService** → Recommends coping strategy
3. **GeminiService** → Generates adaptive response
4. **ElevenLabsService** → Converts to speech
5. **User** → Receives calming, personalized support

### Reward Flow
1. **StressMonitor** → Detects de-escalation
2. **ConversationManager** → Ends session
3. **SolanaService** → Mints CalmToken
4. **AppState** → Updates token balance & streak

## Key Components

### StressMonitor
- Continuously monitors stress via Presage
- Calculates current stress level (calm/rising/spiking)
- Tracks reading history for de-escalation detection

### ConversationManager
- Orchestrates all conversation components
- Manages session lifecycle
- Coordinates AI, personalization, and rewards

### PersonalizationService
- Learns from user's strategy effectiveness
- Recommends best coping strategy per situation
- Updates Gradient AI model with new data

## State Management

- **AppState**: Global app state (tokens, streaks)
- **StressMonitor**: Real-time stress monitoring
- **ConversationManager**: Conversation state
- **WatchConnectivityService**: Watch communication

All use `@Published` properties and `ObservableObject` for SwiftUI reactivity.

## API Integration Pattern

All services follow a similar pattern:
1. Configuration via `Config.swift`
2. Async/await for network calls
3. Error handling with try/catch
4. Published properties for state updates

## Privacy & Security

- Camera data processed locally when possible
- API keys stored securely (use Keychain in production)
- User data anonymized before personalization training
- Blockchain transactions are privacy-preserving

## Testing Strategy

1. **Unit Tests**: Test individual services with mock data
2. **Integration Tests**: Test API integrations with test keys
3. **UI Tests**: Test user flows and stress level changes
4. **Watch Tests**: Test heart rate monitoring and alerts

## Future Enhancements

- Offline mode with local ML models
- Multi-user support with privacy-preserving aggregation
- Integration with health apps (Apple Health, etc.)
- Social features for support exchanges
- Advanced analytics dashboard

