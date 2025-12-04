#!/bin/bash
# Script to list available models for the API key

cat <<EOF > ListModels.swift
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
if let env = EnvLoader.loadEnvFile(at: envPath), let key = env["GOOGLE_API_KEY"] ?? env["GEMINI_API_KEY"] {
    print("✅ Found API Key")
    
    let urlString = "https://generativelanguage.googleapis.com/v1beta/models?key=\(key)"
    guard let url = URL(string: urlString) else { exit(1) }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let semaphore = DispatchSemaphore(value: 0)
    
    print("🚀 Listing available models...")
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data, let str = String(data: data, encoding: .utf8) {
            print("Response: \(str)")
        }
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()
}
EOF

swift ListModels.swift
rm ListModels.swift

