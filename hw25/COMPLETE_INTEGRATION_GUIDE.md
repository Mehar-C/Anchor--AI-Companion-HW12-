# Complete Integration Guide - Anchor

## 🎯 Quick Start: Add Your API Keys

### Option 1: Environment Variables (Recommended)
Set these in your shell or Xcode scheme:
```bash
export PRESAGE_API_KEY="your_key"
export GEMINI_API_KEY="your_key"
export ELEVENLABS_API_KEY="your_key"
export GRADIENT_API_KEY="your_key"
```

### Option 2: Direct in Config.swift (For Testing)
Edit `Anchor/Services/Config.swift`:
```swift
static let presageAPIKey = "your_key_here"
static let geminiAPIKey = "your_key_here"
static let elevenLabsAPIKey = "your_key_here"
static let gradientAPIKey = "your_key_here"
```

## ✅ What's Ready to Use

### 1. **Google Gemini** - ✅ Ready!
- Just add your API key
- Already handles errors gracefully
- Falls back to contextual responses if API fails
- Adaptive responses based on stress levels

**Get API Key**: https://makersuite.google.com/app/apikey

### 2. **ElevenLabs TTS** - ✅ Ready!
- Just add your API key
- Falls back to system TTS if unavailable
- Configured for calming voice

**Get API Key**: https://elevenlabs.io → Dashboard → API Keys

### 3. **Presage** - ⚠️ Needs Implementation
- Camera capture works
- Need to implement actual API call
- Currently simulates data

**Get API Key**: https://presage.ai

### 4. **Gradient AI** - ⚠️ Needs Implementation
- Service structure ready
- Currently uses rule-based recommendations
- Need to implement API calls

**Get API Key**: https://gradient.ai

### 5. **Solana** - ⚠️ Needs SDK
- Service structure ready
- Need to add Solana Swift SDK
- Need wallet setup

**Setup**: See Solana section below

## 🔧 Implementation Status

### ✅ Fully Functional (Just Add Keys)
- **Gemini**: Add key → Works immediately
- **ElevenLabs**: Add key → Works immediately

### ⚠️ Needs Code Implementation
- **Presage**: Need to implement API call in `sendToPresageAPI()`
- **Gradient AI**: Need to implement API calls in `queryGradientModel()`
- **Solana**: Need to add SDK and implement transactions

## 📝 Next Steps

### Priority 1: Get Gemini Working (Easiest)
1. Get API key from Google
2. Add to `Config.swift` or environment
3. Test conversation - should work immediately!

### Priority 2: Get ElevenLabs Working
1. Sign up at ElevenLabs
2. Get API key
3. Add to config
4. Test voice output

### Priority 3: Complete Presage Integration
1. Get Presage API key
2. Implement frame-to-image conversion
3. Implement API request in `PresageService.swift`
4. Parse response

### Priority 4: Gradient AI
1. Set up Gradient AI account
2. Create or access model
3. Implement API calls

### Priority 5: Solana
1. Install Solana Swift SDK
2. Set up wallet
3. Deploy CalmToken
4. Implement minting

## 🎮 Demo Mode

The app works in **demo mode** without any API keys:
- ✅ UI/UX fully functional
- ✅ Stress simulation (random data)
- ✅ Fallback AI responses
- ✅ System TTS fallback
- ✅ All interactions work

Perfect for hackathon demos!

## 🚀 For Hackathon

**Minimum for Demo**:
- Just run the app - it works!
- UI is polished and interactive
- All features visible

**For Full Demo**:
- Add Gemini API key (easiest, most visible)
- Add ElevenLabs key (voice experience)
- Rest can be simulated

## 📞 Need Help?

Each service has error handling and fallbacks, so the app won't crash if APIs fail. Test incrementally!

