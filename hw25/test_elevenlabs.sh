#!/bin/bash

# Create a Swift script to test ElevenLabs TTS
cat <<EOF > TestElevenLabs.swift
import Foundation

class EnvLoader {
    static func loadEnvFile(at path: String) -> [String: String]? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        var env: [String: String] = [:]
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            if let range = trimmed.range(of: "=") {
                let key = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                var value = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                if (value.hasPrefix("\"") && value.hasSuffix("\"")) { value = String(value.dropFirst().dropLast()) }
                if !key.isEmpty { env[key] = value }
            }
        }
        return env
    }
}

let envPath = ".env"
if let env = EnvLoader.loadEnvFile(at: envPath), 
   let key = env["ELEVEN_LABS_API_KEY"] ?? env["ELEVENLABS_API_KEY"] {
    
    print("✅ Found ElevenLabs Key: \(key.prefix(5))...")
    
    let voiceId = "21m00Tcm4TlvDq8ikWAM" // Rachel
    let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(key, forHTTPHeaderField: "xi-api-key")
    
    let body: [String: Any] = [
        "text": "Hello! This is a test of the Eleven Labs voice API.",
        "model_id": "eleven_turbo_v2",
        "voice_settings": [
            "stability": 0.5,
            "similarity_boost": 0.75
        ]
    ]
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: body)
    
    let semaphore = DispatchSemaphore(value: 0)
    
    print("🚀 Testing ElevenLabs API...")
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                print("✅ SUCCESS! ElevenLabs API is working.")
                if let data = data {
                    print("Received Audio Data: \(data.count) bytes")
                }
            } else {
                print("❌ FAILED. Response Code: \(httpResponse.statusCode)")
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("Error Body: \(str)")
                }
            }
        } else if let error = error {
            print("❌ Network Error: \(error.localizedDescription)")
        }
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()
} else {
    print("❌ Could not load ELEVEN_LABS_API_KEY from .env")
}
EOF

swift TestElevenLabs.swift
rm TestElevenLabs.swift

