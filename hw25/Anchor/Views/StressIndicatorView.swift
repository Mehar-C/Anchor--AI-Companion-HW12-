import SwiftUI

struct StressIndicatorView: View {
    let stressLevel: StressLevel
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Animated stress indicator circle
            ZStack {
                // Pulsing background circle
                Circle()
                    .fill(Color(hex: stressLevel.color).opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseScale)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: pulseScale
                    )
                
                // Main circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: stressLevel.color),
                                Color(hex: stressLevel.color).opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: stressIcon)
                            .foregroundColor(.white)
                            .font(.title)
                            .rotationEffect(.degrees(rotation))
                    )
                    .shadow(color: Color(hex: stressLevel.color).opacity(0.5), radius: 12, x: 0, y: 4)
            }
            
            // Description text with animation
            Text(stressLevel.description)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: stressLevel.color))
                .transition(.opacity.combined(with: .scale))
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 28)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        )
        .onAppear {
            pulseScale = 1.2
            withAnimation(
                Animation.linear(duration: 3.0)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
        .onChange(of: stressLevel) { newLevel in
            // Haptic feedback on stress level change
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Visual feedback animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                pulseScale = 1.4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    pulseScale = 1.2
                }
            }
        }
        .onTapGesture {
            // Interactive tap - show more info
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3)) {
                pulseScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3)) {
                    pulseScale = 1.2
                }
            }
        }
    }
    
    private var stressIcon: String {
        switch stressLevel {
        case .calm: return "leaf.fill"
        case .rising: return "exclamationmark.triangle.fill"
        case .spiking: return "heart.fill"
        }
    }
}

#Preview {
    StressIndicatorView(stressLevel: .rising)
}

