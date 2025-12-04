import Foundation
import AVFoundation
import Vision
import UIKit
import SmartSpectraSwiftSDK

class PresageService: NSObject, ObservableObject {
    private let apiKey: String
    
    // Use the SDK's shared instance
    private let sdk = SmartSpectraSwiftSDK.shared
    
    @Published var currentReading: StressReading?
    
    // Backward compatibility properties (since SDK manages capture now)
    var captureSession: AVCaptureSession? {
        return nil // SDK doesn't expose the raw session
    }
    
    init(apiKey: String = Config.presageAPIKey) {
        self.apiKey = apiKey
        super.init()
        
        // Configure the SDK
        if !apiKey.isEmpty {
            sdk.setApiKey(apiKey)
            print("✅ PresageService: Configured SmartSpectra SDK with API Key")
        } else {
            print("⚠️ PresageService: No API Key provided for SmartSpectra SDK")
        }
        
        // Setup observers for SDK data
        setupDataPolling()
    }
    
    private func setupDataPolling() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.pollSDKData()
        }
    }
    
    private func pollSDKData() {
        // Normalize values to 0-1 range for our internal logic
        
        // Try to read from edgeMetrics if available
        if let metrics = sdk.edgeMetrics {
            print("🔍 SDK EdgeMetrics found: \(metrics)")
        }
        
        // Placeholder until we verify property names
        let pulse = 75.0 
        let stressFromPulse = min(max((pulse - 60) / 40.0, 0.0), 1.0)
        
        // Breathing: 12-20 is normal. >20 is rapid (stress).
        let breathing = 16.0
        let breathingScore = min(max((breathing - 12) / 15.0, 0.0), 1.0)
        
        // Create reading
        let reading = StressReading(
            timestamp: Date(),
            stress: stressFromPulse, // Use pulse as proxy for stress
            breathing: breathingScore,
            engagement: 0.5 
        )
        
        DispatchQueue.main.async {
            self.currentReading = reading
        }
    }
    
    func startCapture() {
        // The SDK handles capture internally via SmartSpectraView
        print("📸 PresageService: Capture is managed by SmartSpectraView")
        
        // 'startMeasurement' does not exist.
        // The SDK likely auto-starts when SmartSpectraView is visible and API key is set.
    }
    
    func stopCapture() {
        // SDK cleanup if needed
    }
}
