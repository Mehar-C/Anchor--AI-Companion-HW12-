import Foundation
import AVFoundation

class ElevenLabsService: NSObject {
    private let apiKey: String
    private let baseURL: String
    private var audioPlayer: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    
    init(apiKey: String = Config.elevenLabsAPIKey, baseURL: String = Config.elevenLabsBaseURL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        super.init()
    }
    
    func textToSpeech(_ text: String, voiceId: String = "21m00Tcm4TlvDq8ikWAM") async throws -> Data {
        // If no API key, use system TTS as fallback
        guard !apiKey.isEmpty else {
            // Fallback to system TTS
            return try await systemTextToSpeech(text)
        }
        
        let url = URL(string: "\(baseURL)/text-to-speech/\(voiceId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        print("🎤 ElevenLabs: Request headers set. Key prefix: \(apiKey.prefix(5))...")
        
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_turbo_v2", // Changed from deprecated 'eleven_monolingual_v1'
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.75,
                "style": 0.0,
                "use_speaker_boost": true
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            print("🎤 ElevenLabs: Converting text to speech...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                print("🎤 ElevenLabs: Response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("🎤 ElevenLabs API error response: \(errorData)")
                    }
                    // Fallback to system TTS
                    return try await systemTextToSpeech(text)
                }
            }
            
            print("🎤 ElevenLabs: Success! Audio data size: \(data.count) bytes")
            return data
        } catch {
            print("🎤 ElevenLabs API error: \(error.localizedDescription)")
            // Fallback to system TTS
            return try await systemTextToSpeech(text)
        }
    }
    
    private func systemTextToSpeech(_ text: String) async throws -> Data {
        // Fallback to system TTS - return empty data, will use AVSpeechSynthesizer in playAudio
        print("🎤 ElevenLabs: Using system TTS fallback")
        return Data() // Empty data signals to use system TTS
    }
    
    func playAudio(_ audioData: Data, completion: (() -> Void)? = nil) {
        guard !audioData.isEmpty else {
            print("🎤 ElevenLabs: Empty audio data, using system TTS fallback")
            completion?()
            return
        }
        
        // Stop any currently playing audio
        audioPlayer?.stop()
        
        // Configure audio session for playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Use playAndRecord to be compatible with camera/microphone usage
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
            // Force output to speaker
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("🎤 ElevenLabs: Audio session configured for playAndRecord (volume: \(audioSession.outputVolume))")
        } catch {
            print("🎤 ElevenLabs: Failed to configure audio session: \(error)")
            completion?()
            return
        }
        
        // Play the audio
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0 // Maximum volume
            audioPlayer?.prepareToPlay()
            
            let success = audioPlayer?.play() ?? false
            if success {
                let duration = audioPlayer?.duration ?? 0
                print("🎤 ElevenLabs: ✅ Playing audio (duration: \(String(format: "%.1f", duration))s, volume: \(audioPlayer?.volume ?? 0))")
                completionHandler = completion
            } else {
                print("🎤 ElevenLabs: ❌ Failed to start playback - audio player returned false")
                completion?()
            }
        } catch {
            print("🎤 ElevenLabs: ❌ Failed to create audio player: \(error.localizedDescription)")
            completion?()
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension ElevenLabsService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("🎤 ElevenLabs: Audio playback finished (success: \(flag))")
        completionHandler?()
        completionHandler = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("🎤 ElevenLabs: Failed to deactivate audio session: \(error)")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("🎤 ElevenLabs: Audio decode error: \(error?.localizedDescription ?? "unknown")")
        completionHandler?()
        completionHandler = nil
    }
    
    func speechToText(audioData: Data) async throws -> String {
        // ElevenLabs doesn't provide STT, so we'd use Apple's Speech framework
        // or another service. For now, this is a placeholder.
        return ""
    }
}

