# API Integration Guide

This document provides details on integrating with each external service used by Anchor.

## Presage API

### Purpose
Real-time stress, breathing, and engagement detection from front camera video frames.

### Integration Steps
1. Sign up at https://presage.ai
2. Get your API key
3. Update `Config.presageAPIKey`

### Implementation
In `PresageService.swift`, replace the `sendToPresageAPI` method with actual API calls:

```swift
private func sendToPresageAPI(pixelBuffer: CVPixelBuffer) async -> StressReading {
    // Convert CVPixelBuffer to image data
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent),
          let imageData = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.8) else {
        return StressReading(timestamp: Date(), stress: 0.5, breathing: 0.5, engagement: 0.5)
    }
    
    // Create multipart form data request
    var request = URLRequest(url: URL(string: "\(Config.presageBaseURL)/analyze")!)
    request.httpMethod = "POST"
    request.setValue("Bearer \(Config.presageAPIKey)", forHTTPHeaderField: "Authorization")
    
    // Send image data and get response
    // Parse response to extract stress, breathing, engagement values
    // Return StressReading
}
```

## Google Gemini API

### Purpose
Adaptive AI conversations that change based on stress levels.

### Integration Steps
1. Get API key from https://makersuite.google.com/app/apikey
2. Update `Config.geminiAPIKey`

### Current Implementation
The `GeminiService` already implements the API call. Verify:
- API endpoint is correct for your region
- Model name matches available models (e.g., `gemini-pro`, `gemini-pro-vision`)
- Request format matches current Gemini API version

### Customization
Adjust `buildSystemPrompt` in `GeminiService.swift` to fine-tune:
- Tone and style
- Response length
- Strategy recommendations

## ElevenLabs API

### Purpose
Natural, soothing text-to-speech for hands-free support.

### Integration Steps
1. Sign up at https://elevenlabs.io
2. Get API key from dashboard
3. Update `Config.elevenLabsAPIKey`

### Voice Selection
Default voice ID is `21m00Tcm4TlvDq8ikWAM` (Rachel - calm, soothing). To change:
- Browse voices in ElevenLabs dashboard
- Update `voiceId` parameter in `textToSpeech` method

### Voice Settings
Current settings prioritize calmness:
- `stability: 0.75` - Consistent, calm delivery
- `similarity_boost: 0.75` - Natural voice
- `style: 0.5` - Balanced style
- `use_speaker_boost: true` - Enhanced clarity

## DigitalOcean Gradient AI

### Purpose
Personalized coping strategy recommendations based on user history.

### Integration Steps
1. Sign up at https://gradient.ai
2. Create a model or use existing one
3. Get API key
4. Update `Config.gradientAPIKey`

### Model Setup
1. Create a fine-tunable model for recommendation
2. Train with initial dataset of strategy effectiveness
3. Update `queryGradientModel` in `PersonalizationService.swift`:

```swift
private func queryGradientModel(...) async -> CopingStrategy? {
    let url = URL(string: "\(baseURL)/models/your-model-id/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let prompt = buildRecommendationPrompt(stressLevel, recentReadings, history)
    let body: [String: Any] = [
        "prompt": prompt,
        "max_tokens": 50
    ]
    
    // Send request and parse response
    // Return recommended CopingStrategy
}
```

### Fine-tuning
Use `updateGradientModel` to periodically fine-tune with new user data:
- Collect strategy effectiveness data
- Format as training examples
- Submit fine-tuning job to Gradient AI

## Solana Integration

### Purpose
Mint CalmTokens as rewards for successful de-escalation.

### Integration Steps
1. Install Solana SDK (e.g., via Swift Package Manager):
   ```swift
   // Add to Package.swift or Xcode SPM
   .package(url: "https://github.com/p2p-org/solana-swift", from: "0.0.1")
   ```

2. Set up wallet:
   - Generate or import keypair
   - Store securely (use Keychain)

3. Deploy or configure CalmToken:
   - Create SPL token mint (or use existing)
   - Update `Config.calmTokenMint`

### Implementation
Update `SolanaService.swift`:

```swift
import SolanaSwift

func mintCalmToken(amount: Int = 1) async throws -> String {
    let api = APIClient(endpoint: .init(address: "https://api.devnet.solana.com", network: .devnet))
    let keypair = try Keypair(secretKey: yourSecretKey)
    
    // Create mint instruction
    // Create associated token account if needed
    // Mint tokens to user's account
    
    let transaction = try Transaction()
    // Add instructions
    // Sign transaction
    // Send and confirm
    
    return transactionSignature
}
```

### Network Selection
- `devnet`: For testing (free, no real value)
- `mainnet-beta`: For production (requires SOL for fees)

## Testing Without API Keys

For development/demo purposes, the app includes simulation modes:
- Presage: Returns random stress readings
- Heart Rate: Simulates heart rate data if HealthKit unavailable
- Solana: Returns simulated transaction signatures

To enable full functionality, add all API keys to your environment or `Config.swift`.

