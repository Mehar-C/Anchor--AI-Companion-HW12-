import Foundation
import Combine
import AVFoundation

class ConversationManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isSpeaking: Bool = false
    @Published var isListening: Bool = false
    @Published var currentSession: Session?
    
    private let geminiService = GeminiService()
    private let elevenLabsService = ElevenLabsService()
    private let personalizationService = PersonalizationService()
    private let solanaService = SolanaService()
    
    private var sessionStartStress: Double?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speechDelegate: SpeechCompletionDelegate?
    
    func startSession(stressLevel: StressLevel, initialReading: StressReading) {
        currentSession = Session(
            id: UUID(),
            startTime: Date(),
            stressLevels: [initialReading],
            copingStrategies: []
        )
        sessionStartStress = initialReading.stress
    }
    
    func sendMessage(_ text: String, stressLevel: StressLevel) async {
        print("💬 ConversationManager: sendMessage called with text: '\(text)'")
        print("💬 ConversationManager: Current message count: \(messages.count)")
        
        // Add user message
        let userMessage = ChatMessage(role: .user, content: text, timestamp: Date())
        await MainActor.run {
            messages.append(userMessage)
            print("💬 ConversationManager: Added user message. Total messages: \(messages.count)")
        }
        
        // Get recommended strategy
        let recentReadings = currentSession?.stressLevels ?? []
        let strategy = await personalizationService.recommendStrategy(
            stressLevel: stressLevel,
            recentReadings: recentReadings
        )
        
        // Get latest reading for breathing/heart rate data
        let latestReading = currentSession?.stressLevels.last
        // Only pass breathing rate if Presage is actually active and providing real data
        // We can check if the reading timestamp is very recent (e.g. within last 5 seconds)
        // and ideally if we had a flag for "isActive", but timestamp is a good proxy.
        var breathingRate: Double? = nil
        
        if let reading = latestReading, abs(reading.timestamp.timeIntervalSinceNow) < 5.0 {
             // Assuming if we have a recent reading, the camera is on and tracking
             breathingRate = reading.breathing
             print("💬 ConversationManager: Passing real breathing rate: \(String(format: "%.2f", reading.breathing))")
        } else {
             print("💬 ConversationManager: No active tracking (camera off/old data), skipping breathing rate.")
        }
        
        let heartRate: Double? = nil // TODO: Get from WatchConnectivityService
        
        // Get conversation history for Gemini (includes the user message we just added)
        let conversationHistory = await MainActor.run {
            messages.map { Message(role: $0.role.rawValue, content: $0.content) }
        }
        
        print("💬 ConversationManager: Sending to Gemini with \(conversationHistory.count) messages in history")
        for (index, msg) in conversationHistory.enumerated() {
            print("💬   [\(index)] \(msg.role): \(msg.content.prefix(50))...")
        }
        
        // Generate AI response
        do {
            print("💬 ConversationManager: Generating AI response via Gemini...")
            print("💬 ConversationManager: API Key exists: \(!Config.geminiAPIKey.isEmpty)")
            print("💬 ConversationManager: Base URL: \(Config.geminiBaseURL)")
            
            let responseText = try await geminiService.generateResponse(
                stressLevel: stressLevel,
                recommendedStrategy: strategy,
                conversationHistory: conversationHistory,
                breathingRate: breathingRate,
                heartRate: heartRate
            )
            
            print("💬 ConversationManager: ✅ Got response from Gemini: '\(responseText.prefix(100))...'")
            
            let aiMessage = ChatMessage(role: .assistant, content: responseText, timestamp: Date())
            await MainActor.run {
                messages.append(aiMessage)
                print("💬 ConversationManager: ✅ Added AI message to UI. Total messages: \(messages.count)")
                print("💬 ConversationManager: Message content: \(responseText.prefix(50))...")
            }
            
            // Speak the response
            print("💬 ConversationManager: Speaking response...")
            await speakResponse(responseText)
            print("💬 ConversationManager: ✅ Speech started")
            
            // Update session
            if let strategy = strategy {
                await MainActor.run {
                    currentSession?.copingStrategies.append(strategy)
                }
            }
        } catch {
            print("💬 ConversationManager: ERROR - Gemini API failed: \(error.localizedDescription)")
            print("💬 ConversationManager: This should not happen - check API key and network connection")
            
            // Show error to user instead of fallback
            let errorMessage = ChatMessage(
                role: .assistant,
                content: "I'm having trouble connecting right now. Please check your internet connection and try again.",
                timestamp: Date()
            )
            await MainActor.run {
                messages.append(errorMessage)
            }
            
            // Still try to speak the error message
            await speakResponse(errorMessage.content)
        }
    }
    
    func speakResponse(_ text: String) async {
        await MainActor.run {
            isSpeaking = true
            print("🔊 ConversationManager: Starting speech synthesis for: '\(text.prefix(50))...'")
        }
        
        // FORCE RESET AUDIO SESSION BEFORE SPEAKING
        // This handles cases where Presage/Camera SDK might have hijacked the session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            // Explicitly override output to speaker
            try audioSession.overrideOutputAudioPort(.speaker)
            print("🔊 ConversationManager: FORCED audio session to speaker")
        } catch {
            print("🔊 ConversationManager: ⚠️ Failed to force audio session: \(error)")
        }
        
        // Stop any current speech (System and ElevenLabs)
        await MainActor.run {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        elevenLabsService.stopAudio()
        
        // Try ElevenLabs first
        do {
            print("🔊 ConversationManager: Attempting ElevenLabs TTS...")
            let audioData = try await elevenLabsService.textToSpeech(text)
            
            if !audioData.isEmpty {
                print("🔊 ConversationManager: ✅ Got ElevenLabs audio (\(audioData.count) bytes)")
                
                await withCheckedContinuation { continuation in
                    elevenLabsService.playAudio(audioData) {
                        Task { @MainActor in
                            self.isSpeaking = false
                            print("🔊 ConversationManager: ✅ ElevenLabs speech finished")
                            continuation.resume()
                        }
                    }
                }
                return
            }
        } catch {
            print("🔊 ConversationManager: ElevenLabs failed (\(error.localizedDescription)), falling back to system TTS")
        }
        
        // Fallback to System TTS if ElevenLabs fails or returns empty data
        await MainActor.run {
            print("🔊 ConversationManager: Using System TTS fallback")
            
            // Configure audio session for speech
            do {
                let audioSession = AVAudioSession.sharedInstance()
                // Use playAndRecord to ensure we can play audio even if camera/mic is active
                // allowBluetooth and defaultToSpeaker are critical for hands-free
                try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                print("🔊 ConversationManager: Audio session configured for PlayAndRecord")
            } catch {
                print("🔊 ConversationManager: ⚠️ Audio session error: \(error)")
            }
            
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.48 // Slower, more calming
            utterance.pitchMultiplier = 0.9 // Slightly lower pitch
            utterance.volume = 1.0 // Maximum volume
            
            // Create and retain delegate to prevent deallocation
            speechDelegate = SpeechCompletionDelegate { [weak self] in
                Task { @MainActor in
                    self?.isSpeaking = false
                    print("🔊 ConversationManager: ✅ System speech finished")
                }
            }
            
            // Set delegate to track completion
            speechSynthesizer.delegate = speechDelegate
            
            // Try to find a better voice than the default
            let preferredVoices = ["com.apple.voice.compact.en-US.Samantha", "com.apple.ttsbundle.Samantha-compact", "com.apple.speech.voice.Alex"]
            var selectedVoice = AVSpeechSynthesisVoice(language: "en-US")
            
            for voiceId in preferredVoices {
                if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
                    selectedVoice = voice
                    print("🔊 ConversationManager: Using enhanced system voice: \(voiceId)")
                    break
                }
            }
            
            utterance.voice = selectedVoice
            print("🔊 ConversationManager: Speaking with system TTS")
            speechSynthesizer.speak(utterance)
        }
    }
    
    func endSession(hasDeEscalated: Bool, finalReading: StressReading) async {
        // Get session on main actor
        let session = await MainActor.run { currentSession }
        guard let session = session else { return }
        
        // Create updated session (structs are value types, so we can modify a copy)
        var updatedSession = session
        updatedSession.endTime = Date()
        updatedSession.successful = hasDeEscalated
        updatedSession.stressLevels.append(finalReading)
        
        // Record strategy effectiveness (can be done off main actor)
        let strategies = updatedSession.copingStrategies
        if let startStress = sessionStartStress {
            for strategy in strategies {
                await personalizationService.recordStrategyEffectiveness(
                    strategy: strategy,
                    initialStress: startStress,
                    finalStress: finalReading.stress
                )
            }
        }
        
        // Mint CalmTokens if successful (can be done off main actor)
        if hasDeEscalated {
            do {
                let txSignature = try await solanaService.mintCalmToken(amount: 1)
                print("Minted CalmToken: \(txSignature)")
            } catch {
                print("Error minting token: \(error)")
            }
        }
        
        // Update session on main actor
        await MainActor.run { [updatedSession] in
            currentSession = updatedSession
            sessionStartStress = nil
        }
    }
}

// Helper to track speech completion
class SpeechCompletionDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onFinish()
    }
}

struct ChatMessage: Identifiable, Codable {
    var id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    init(role: MessageRole, content: String, timestamp: Date) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}

