import Foundation

struct Config {
    // Presage API
    static let presageAPIKey: String = {
        EnvLoader.load()
        let key = EnvLoader.get("PRESAGE_API_KEY") ?? ""
        if key.isEmpty {
            print("⚠️ Config: No Presage API key found - please set PRESAGE_API_KEY in .env file")
        }
        return key
    }()
    static let presageBaseURL = "https://api.presage.ai/v1"
    
    // Google Gemini API
    // Check GOOGLE_API_KEY first (from .env), then GEMINI_API_KEY (backward compatibility), then fallback
    static let geminiAPIKey: String = {
        // Load .env file if available
        EnvLoader.load()
        
        // Try GOOGLE_API_KEY first (user's .env file)
        if let googleKey = EnvLoader.get("GOOGLE_API_KEY"), !googleKey.isEmpty {
            print("✅ Config: Using GOOGLE_API_KEY from .env file")
            return googleKey
        }
        
        // Try GEMINI_API_KEY (backward compatibility)
        if let geminiKey = EnvLoader.get("GEMINI_API_KEY"), !geminiKey.isEmpty {
            print("✅ Config: Using GEMINI_API_KEY from .env file")
            return geminiKey
        }
        
        // Fallback to environment variable or empty
        let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? 
                     ProcessInfo.processInfo.environment["GOOGLE_API_KEY"] ?? 
                     ""
        
        if !envKey.isEmpty {
            print("✅ Config: Using API key from environment variable")
        } else {
            print("⚠️ Config: No API key found - please set GOOGLE_API_KEY in .env file")
        }
        
        return envKey
    }()
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    
    // ElevenLabs API
    static let elevenLabsAPIKey: String = {
        EnvLoader.load()
        // Check both ELEVEN_LABS_API_KEY (as requested) and ELEVENLABS_API_KEY (standard convention)
        let key = EnvLoader.get("ELEVEN_LABS_API_KEY") ?? EnvLoader.get("ELEVENLABS_API_KEY") ?? ""
        if key.isEmpty {
            print("⚠️ Config: No ElevenLabs API key found - please set ELEVEN_LABS_API_KEY in .env file")
        } else {
            print("✅ Config: Loaded ElevenLabs Key (Starts with: \(key.prefix(4))...)")
        }
        return key
    }()
    static let elevenLabsBaseURL = "https://api.elevenlabs.io/v1"
    
    // DigitalOcean Gradient AI
    static let gradientAPIKey = ProcessInfo.processInfo.environment["GRADIENT_API_KEY"] ?? ""
    static let gradientBaseURL = "https://api.gradient.ai"
    
    // Solana Configuration
    static let solanaNetwork = "devnet" // or "mainnet-beta"
    static let calmTokenMint = "CalmTokenMintAddress" // Replace with actual mint address
}

/// Simple .env file loader for iOS
class EnvLoader {
    private static var loadedEnv: [String: String] = [:]
    private static var hasLoaded = false
    
    /// Load environment variables from .env file
    static func load() {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        // Try to find .env file in bundle or project directory
        let envPaths = [
            Bundle.main.path(forResource: ".env", ofType: nil),
            Bundle.main.bundlePath.appending("/.env"),
            // For development, try project root
            FileManager.default.currentDirectoryPath.appending("/.env"),
            // Try absolute path from project root
            "/Users/meharchatha/Desktop/hw25/.env"
        ]
        
        for envPath in envPaths.compactMap({ $0 }) {
            if let env = loadEnvFile(at: envPath) {
                loadedEnv = env
                print("✅ EnvLoader: Loaded .env from \(envPath)")
                return
            }
        }
        
        print("⚠️ EnvLoader: No .env file found, using environment variables only")
    }
    
    /// Load .env file from path
    private static func loadEnvFile(at path: String) -> [String: String]? {
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }
        
        var env: [String: String] = [:]
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines and comments
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            
            // Parse KEY=VALUE format
            if let range = trimmed.range(of: "=") {
                let key = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                var value = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                
                // Remove quotes if present
                if (value.hasPrefix("\"") && value.hasSuffix("\"")) || 
                   (value.hasPrefix("'") && value.hasSuffix("'")) {
                    value = String(value.dropFirst().dropLast())
                }
                
                if !key.isEmpty {
                    env[key] = value
                    // Debug log for loaded keys (masked)
                    if key.contains("KEY") || key.contains("SECRET") {
                        let mask = String(repeating: "*", count: max(0, value.count - 4))
                        let suffix = value.suffix(4)
                        print("   🔑 Loaded \(key): \(mask)\(suffix)")
                    }
                }
            }
        }
        
        return env
    }
    
    /// Get environment variable value
    static func get(_ key: String) -> String? {
        load() // Ensure we've loaded
        return loadedEnv[key] ?? ProcessInfo.processInfo.environment[key]
    }
}
