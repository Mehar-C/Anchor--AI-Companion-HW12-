import Foundation

class GeminiService {
    private let apiKey: String
    private let baseURL: String
    
    init(apiKey: String = Config.geminiAPIKey, baseURL: String = Config.geminiBaseURL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        
        if self.apiKey.isEmpty {
            print("❌ CRITICAL: Gemini Service initialized without API Key!")
            print("👉 Make sure you have a .env file with GOOGLE_API_KEY=...")
            print("👉 Make sure .env is added to your 'Copy Bundle Resources' in Xcode Build Phases")
        } else {
            print("✅ Gemini Service initialized with API Key (Length: \(self.apiKey.count))")
        }
    }
    
    func generateResponse(
        stressLevel: StressLevel,
        recommendedStrategy: CopingStrategy?,
        conversationHistory: [Message],
        breathingRate: Double? = nil,
        heartRate: Double? = nil
    ) async throws -> String {
        // If no API key, return a contextual fallback response
        guard !apiKey.isEmpty else {
            return getFallbackResponse(stressLevel: stressLevel, strategy: recommendedStrategy)
        }
        
        // Use the correct Gemini API endpoint
        // Using gemini-2.0-flash as confirmed by ListModels API
        let modelName = "gemini-2.0-flash" 
        let url = URL(string: "\(baseURL)/models/\(modelName):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        // Build context-aware prompt with conversation history
        let systemPrompt = buildSystemPrompt(
            stressLevel: stressLevel,
            strategy: recommendedStrategy,
            breathingRate: breathingRate,
            heartRate: heartRate
        )
        
        // Build conversation history - Gemini format
        var contents: [[String: Any]] = []
        
        // Always include system prompt as the first message
        contents.append([
            "role": "user",
            "parts": [["text": systemPrompt]]
        ])
        
        // Add conversation history (last 10 messages for context)
        // The conversationHistory includes the user's latest message
        if !conversationHistory.isEmpty {
            let recentHistory = Array(conversationHistory.suffix(10))
            print("🔵 Gemini: Adding \(recentHistory.count) messages to context")
            for (index, message) in recentHistory.enumerated() {
                // Map "assistant" to "model" for Gemini API
                let role = message.role == "assistant" ? "model" : "user"
                
                print("🔵 Gemini:   [\(index)] \(role) (orig: \(message.role)): '\(message.content.prefix(40))...'")
                contents.append([
                    "role": role,
                    "parts": [["text": message.content]]
                ])
            }
        } else {
            print("🔵 Gemini: No conversation history - this is the first message")
        }
        
        let requestBody: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": stressLevel == .spiking ? 0.7 : 0.9,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": stressLevel == .spiking ? 150 : 300
            ]
        ]
        
        // Debug: Print request details
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🔵 Gemini: Request body:\n\(jsonString)")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            print("🔵 Gemini: Sending request to API...")
            print("🔵 Gemini: URL: \(url.absoluteString.prefix(80))...")
            print("🔵 Gemini: Request method: \(request.httpMethod ?? "nil")")
            print("🔵 Gemini: API Key present: \(!apiKey.isEmpty)")
            print("🔵 Gemini: Conversation history length: \(conversationHistory.count)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                print("🔵 Gemini: Response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("🛑 Gemini API Error Body: \(errorData)")
                    }
                    print("⚠️ Gemini: HTTP error \(httpResponse.statusCode)")
                    
                    // If 400/403, it's likely an API key or request issue.
                    // If 429, it's quota.
                    // If 5xx, it's Google's side.
                    
                    if httpResponse.statusCode == 400 {
                         print("👉 Check your request format or API key validity.")
                    } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                         print("👉 Check your API KEY. It may be invalid or missing permissions.")
                    }
                    
                    print("\n⚠️ GEMINI FAILURE TRIGGERING GENERIC FALLBACK RESPONSE")
                    print("⚠️ If you are seeing 'generic lines', this is why.")
                    print("⚠️ Please verify your GOOGLE_API_KEY in .env\n")
                    
                    return getFallbackResponse(stressLevel: stressLevel, strategy: recommendedStrategy)
                }
            }
            
            // Debug: Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                // print("🔵 Gemini: Raw response: \(responseString.prefix(500))...") 
                // Commented out to reduce noise, only print on error or success
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let candidate = geminiResponse.candidates.first,
                  let text = candidate.content.parts.first?.text,
                  !text.isEmpty else {
                print("🔵 Gemini: No valid response text in API response")
                throw NSError(domain: "GeminiService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response from Gemini API"])
            }
            
            print("🔵 Gemini: Success! Response: \(text)")
            print("🔵 Gemini: Response length: \(text.count) chars")
            return text
        } catch {
            print("🔵 Gemini API error: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("🔵 Gemini Decoding error: \(decodingError)")
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("🔵 Missing key: \(key.stringValue) in \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("🔵 Type mismatch: expected \(type) in \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("🔵 Value not found: \(type) in \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("🔵 Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("🔵 Unknown decoding error")
                }
            }
            // Don't use fallback - throw error so caller knows API failed
            throw error
        }
    }
    
    private func getFallbackResponse(stressLevel: StressLevel, strategy: CopingStrategy?) -> String {
        // Fallback responses when API is unavailable
        // We use randomization to make the offline experience feel less robotic
        
        let strategyText = strategy?.rawValue ?? "calming techniques"
        
        switch stressLevel {
        case .calm:
            let responses = [
                "I'm here with you. You're doing well. How can I support you today?",
                "It's good to connect with you. I'm listening if there's anything on your mind.",
                "I'm glad you're feeling steady. Is there anything you'd like to talk about?"
            ]
            return responses.randomElement() ?? responses[0]
            
        case .rising:
            let responses = [
                "I notice you might be feeling some stress. Let's take a moment together. Would you like to try a breathing exercise?",
                "It seems like things are a bit intense right now. I'm here. Shall we try some \(strategyText)?",
                "Take a slow breath. I'm right here with you. What's causing you stress at the moment?"
            ]
            return responses.randomElement() ?? responses[0]
            
        case .spiking:
            let responses = [
                "I'm here with you right now. Let's focus on getting you grounded. Can you tell me what you're experiencing?",
                "You're safe. Let's just breathe together for a moment. Deep breath in... and out.",
                "I can sense this is difficult. Focus on my voice (or text). Let's use \(strategyText) to get through this moment together."
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
    
    private func buildSystemPrompt(
        stressLevel: StressLevel,
        strategy: CopingStrategy?,
        breathingRate: Double? = nil,
        heartRate: Double? = nil
    ) -> String {
        var prompt = """
        You are Anchor, a compassionate AI companion helping someone manage anxiety in real-time using Presage technology that tracks their physiological state.
        
        Current stress level: \(stressLevel.rawValue)
        
        """
        
        // Add breathing pattern data
        if let breathing = breathingRate {
            let breathingStatus: String
            if breathing < 0.3 {
                breathingStatus = "very shallow or rapid"
            } else if breathing < 0.5 {
                breathingStatus = "somewhat irregular"
            } else if breathing < 0.7 {
                breathingStatus = "moderately steady"
            } else {
                breathingStatus = "calm and steady"
            }
            prompt += "Breathing pattern: \(breathingStatus) (detected via Presage facial analysis)\n"
        }
        
        // Add heart rate data if available
        if let hr = heartRate {
            prompt += "Heart rate: Elevated (detected via Apple Watch)\n"
        }
        
        if let strategy = strategy {
            prompt += "Recommended coping strategy: \(strategy.rawValue)\n\n"
        }
        
        // Adaptive questioning based on physiological data
        prompt += "\nADAPTIVE QUESTIONING GUIDELINES:\n"
        
        if let breathing = breathingRate, breathing < 0.4 {
            prompt += "- The user's breathing is shallow/rapid. Ask gentle questions like: 'I notice your breathing might be quick. Can you tell me what's on your mind?' or 'Let's try a breathing exercise together. Can you take a slow breath with me?'\n"
        }
        
        if let hr = heartRate {
            prompt += "- The user's heart rate is elevated. Ask: 'I sense you might be feeling anxious. What's happening for you right now?' or 'Would it help to talk through what you're experiencing?'\n"
        }
        
        switch stressLevel {
        case .calm:
            prompt += "\nThe user is in a calm state. Be supportive, gentle, and maintain a positive connection. Keep responses brief and warm. You can ask about their day or what's on their mind."
        case .rising:
            prompt += "\nThe user's stress is rising. Be more attentive, offer gentle guidance, and suggest calming techniques. Ask specific questions like: 'What's making you feel stressed right now?' or 'Would a breathing exercise help?' Keep responses moderate in length."
        case .spiking:
            prompt += "\nThe user is experiencing high stress. Be very calm, reassuring, and focused. Use shorter, simpler sentences. Ask grounding questions like: 'Can you name 3 things you can see around you?' or 'Let's take a deep breath together. Can you try that with me?' Prioritize immediate calming techniques."
        }
        
        prompt += "\n\nIMPORTANT: Based on the breathing patterns and stress level, ask specific, adaptive questions that help distract or ground the user. Be conversational and natural, not clinical."
        prompt += "\n\nCRITICAL: Always respond directly to what the user just said. Read their message carefully and address their specific concerns, questions, or statements. Do not give generic responses - personalize your reply based on their actual words."
        prompt += "\n\nAlways be empathetic, non-judgmental, and supportive. This is not a replacement for professional care."
        
        return prompt
    }
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]
    
    struct Candidate: Codable {
        let content: Content
        
        struct Content: Codable {
            let parts: [Part]
            
            struct Part: Codable {
                let text: String
            }
        }
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

