import SwiftUI
import AVFoundation
import SmartSpectraSwiftSDK

struct CameraPreviewView: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    @State private var isPresageActive = false
    
    // Use the SDK's shared instance for data access
    // Note: If 'SmartSpectraSwiftSDK.shared' doesn't exist, check SDK docs for correct singleton
    // Trying SmartSpectraSwiftSDK based on package name
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    
    var body: some View {
        VStack(spacing: 12) {
            // Camera preview area
            if isPresageActive {
                // Use the REAL SDK View directly - minimized wrapping to avoid presentation conflicts
                SmartSpectraView()
                    .frame(minHeight: 450)
                    .cornerRadius(24)
                    .onAppear {
                        if let apiKey = Config.presageAPIKey as String?, !apiKey.isEmpty {
                            sdk.setApiKey(apiKey)
                            print("✅ SmartSpectraView: API Key set")
                        }
                        // Hide SDK's default UI so we can show our custom sleek dashboard
                        sdk.showControlsInScreeningView(false)
                        
                        // Explicitly set camera position to Front to ensure session starts
                        sdk.setCameraPosition(.front) 
                        
                        stressMonitor.startMonitoring()
                    }
                    .overlay(alignment: .bottom) {
                        VitalsDashboardView()
                            .environmentObject(stressMonitor)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 20)
                    }
                    .onDisappear {
                        stressMonitor.stopMonitoring()
                    }
            } else {
                // Placeholder when inactive
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .fill(Theme.Colors.surface)
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                            Text("Activate Presage")
                                .font(Theme.Typography.caption())
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .shadow(color: Theme.Colors.cardShadow, radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
            }
            
            // Toggle button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                withAnimation {
                    isPresageActive.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: isPresageActive ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(isPresageActive ? "Deactivate Camera" : "Start Monitoring")
                        .font(Theme.Typography.body())
                }
                .foregroundColor(isPresageActive ? Theme.Colors.error : Theme.Colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.surface)
                        .shadow(color: Theme.Colors.cardShadow, radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isPresageActive ? Theme.Colors.error.opacity(0.3) : Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// Custom Sleek Dashboard for Vitals
struct VitalsDashboardView: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    
    // Use stressMonitor data. If no data yet, show placeholders
    private var pulseRate: String {
        // Use the latest reading from the readings array
        if let reading = stressMonitor.readings.last {
            // Map 0-1 stress to 60-100 bpm for demo if raw data missing
            let estimatedBPM = 60 + (reading.stress * 40)
            return String(format: "%.0f", estimatedBPM)
        }
        return "--"
    }
    
    private var breathingRate: String {
        if let reading = stressMonitor.readings.last {
            let estimatedBR = 12 + (reading.breathing * 8)
            return String(format: "%.0f", estimatedBR)
        }
        return "--"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Pulse Card
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFEBEE"))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "heart.fill")
                        .foregroundColor(Color(hex: "EF5350"))
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pulse")
                        .font(Theme.Typography.caption())
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(pulseRate)
                            .font(Theme.Typography.header(size: 24))
                            .foregroundColor(Theme.Colors.textPrimary)
                        Text("BPM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.surface)
            .cornerRadius(16)
            .shadow(color: Theme.Colors.cardShadow, radius: 8, x: 0, y: 4)
            
            // Breathing Card
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E3F2FD"))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "lungs.fill")
                        .foregroundColor(Color(hex: "42A5F5"))
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Breathing")
                        .font(Theme.Typography.caption())
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(breathingRate)
                            .font(Theme.Typography.header(size: 24))
                            .foregroundColor(Theme.Colors.textPrimary)
                        Text("RPM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.surface)
            .cornerRadius(16)
            .shadow(color: Theme.Colors.cardShadow, radius: 8, x: 0, y: 4)
        }
    }
}
