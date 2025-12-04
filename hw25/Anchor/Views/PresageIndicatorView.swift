import SwiftUI

struct PresageIndicatorView: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    @State private var isPulsing = false
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: 8) {
            // Pulsing indicator dot
            ZStack {
                Circle()
                    .fill(Color(hex: "4CAF50").opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0.3 : 1.0)
                
                Circle()
                    .fill(Color(hex: "4CAF50"))
                    .frame(width: 8, height: 8)
            }
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            
            // Status text
            VStack(alignment: .leading, spacing: 2) {
                Text("Presage Active")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if let latestReading = stressMonitor.readings.last {
                    HStack(spacing: 4) {
                        Label("Breathing", systemImage: "lungs.fill")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("\(Int(latestReading.breathing * 100))%")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Rotating icon
            Image(systemName: "waveform.path")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4CAF50"))
                .rotationEffect(.degrees(rotation))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color(hex: "4CAF50").opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "4CAF50").opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            isPulsing = true
            withAnimation(
                Animation.linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }
}

#Preview {
    PresageIndicatorView()
        .environmentObject(StressMonitor())
        .padding()
}

