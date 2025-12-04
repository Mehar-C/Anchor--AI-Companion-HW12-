import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var heartRateMonitor = HeartRateMonitor()
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Heart rate display
            VStack {
                Text("\(Int(heartRateMonitor.currentHeartRate))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(heartRateColor)
                
                Text("BPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stress indicator
            if heartRateMonitor.stressDetected {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Stress Detected")
                        .font(.headline)
                    
                    Button("Open Anchor") {
                        openAnchorApp()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .onAppear {
            heartRateMonitor.startMonitoring()
        }
        .onChange(of: heartRateMonitor.stressDetected) { detected in
            if detected {
                showAlert = true
            }
        }
        .alert("Stress Spike Detected", isPresented: $showAlert) {
            Button("Open Anchor") {
                openAnchorApp()
            }
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text("Your heart rate suggests increased stress. Would you like to open Anchor for support?")
        }
    }
    
    private var heartRateColor: Color {
        if heartRateMonitor.stressDetected {
            return .orange
        } else if heartRateMonitor.currentHeartRate > 100 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private func openAnchorApp() {
        // Open the iOS Anchor app
        if let url = URL(string: "anchor://open") {
            WKExtension.shared().openSystemURL(url)
        }
    }
}

#Preview {
    ContentView()
}

