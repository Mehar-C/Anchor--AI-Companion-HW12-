# Anchor Setup Guide

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- watchOS 10.0+ (for watch companion)
- API keys for all services

## API Keys Configuration

Create a `.env` file or set environment variables with:

```bash
export PRESAGE_API_KEY="your_presage_key"
export GEMINI_API_KEY="your_gemini_key"
export ELEVENLABS_API_KEY="your_elevenlabs_key"
export GRADIENT_API_KEY="your_gradient_key"
```

Alternatively, update `Anchor/Services/Config.swift` directly with your keys (not recommended for production).

## Solana Configuration

1. Set up a Solana wallet
2. Deploy or configure the CalmToken mint address
3. Update `Config.calmTokenMint` with your mint address
4. Choose network: `devnet` (for testing) or `mainnet-beta` (for production)

## Building the Project

1. Open `Anchor.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run on your iOS device
4. Build and run the watchOS app on a paired Apple Watch

## Features to Implement

### Presage Integration
- Replace simulated analysis in `PresageService.swift` with actual API calls
- Send camera frames to Presage API
- Process stress, breathing, and engagement metrics

### Google Gemini
- Verify API key and endpoint
- Adjust prompt engineering for better responses
- Add conversation context management

### ElevenLabs
- Configure voice settings for calming tone
- Test TTS quality and latency
- Implement proper audio session management

### DigitalOcean Gradient AI
- Set up model training pipeline
- Implement fine-tuning with user data
- Create recommendation endpoint

### Solana Integration
- Set up Solana SDK (e.g., SolanaSwift)
- Implement wallet connection
- Create token minting transaction
- Add transaction confirmation handling

## Testing

- Test stress detection with various scenarios
- Verify conversation adaptation based on stress levels
- Test voice input/output functionality
- Validate CalmToken minting on devnet
- Test watchOS companion app alerts

## Privacy & Security

- All stress data is processed locally when possible
- API keys should be stored securely (use Keychain)
- User data is anonymized before sending to personalization model
- CalmToken transactions are privacy-preserving (no personal data on-chain)

## Disclaimer

Anchor is a supportive tool and is not a replacement for professional mental health care. Users experiencing severe anxiety or mental health crises should seek professional help.

