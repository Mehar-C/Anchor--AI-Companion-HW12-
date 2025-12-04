# Anchor Quick Start Guide

Get Anchor running in 5 minutes for hackathon demo.

## Step 1: Open Project

```bash
cd /Users/meharchatha/Desktop/hw25
open Anchor.xcodeproj
```

## Step 2: Configure API Keys (Optional for Demo)

For a full demo, you'll need API keys. For a basic demo without APIs:

1. The app will work in simulation mode
2. Stress readings will be simulated
3. Heart rate will be simulated if HealthKit unavailable
4. AI responses will need Gemini API key

### Quick API Key Setup

Edit `Anchor/Services/Config.swift`:

```swift
static let geminiAPIKey = "YOUR_KEY_HERE"  // Required for conversations
static let presageAPIKey = "YOUR_KEY_HERE" // Optional - uses simulation
static let elevenLabsAPIKey = "YOUR_KEY_HERE" // Optional - uses system TTS
```

## Step 3: Build & Run

1. Select your iOS device or simulator
2. Press ⌘R to build and run
3. Grant camera and microphone permissions when prompted

## Step 4: Test the App

### Basic Flow
1. App opens → Camera starts → Stress monitoring begins
2. Type a message → AI responds (if Gemini key set)
3. Tap microphone → Speak → Voice recognition
4. Tap "End Session" → See summary

### Watch Companion
1. Build `AnchorWatch` target
2. Run on paired Apple Watch
3. Watch detects simulated heart rate spikes
4. Tap "Open Anchor" to launch iPhone app

## Demo Mode Features

Even without API keys, you can demo:
- ✅ UI/UX and calming interface
- ✅ Stress level visualization
- ✅ Conversation interface (with mock responses)
- ✅ Voice controls (using system speech recognition)
- ✅ Session management
- ✅ Watch connectivity

## Troubleshooting

### Camera Not Working
- Check Info.plist has camera permission
- Verify entitlements include camera access
- Test on physical device (simulator has limited camera)

### Watch Not Connecting
- Ensure both apps are installed
- Check WatchConnectivity is supported
- Verify watch and phone are paired

### API Errors
- Check API keys are correct
- Verify network connectivity
- Check API rate limits

## Next Steps

1. **Add Real APIs**: See `API_INTEGRATION.md`
2. **Customize UI**: Edit views in `Anchor/Views/`
3. **Add Features**: Extend services in `Anchor/Services/`
4. **Deploy**: Follow `SETUP.md` for production

## Hackathon Tips

- Focus on one API integration at a time
- Use simulation mode for demos if APIs are slow
- Test on physical device for best experience
- Prepare backup demo video if live demo fails

Good luck! 🚀

