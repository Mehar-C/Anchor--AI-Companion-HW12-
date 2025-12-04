import SwiftUI

struct AnimatedGradientBackgroundView: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "E8F5E9"),
                Color(hex: "C8E6C9"),
                Color(hex: "A5D6A7"),
                Color(hex: "C8E6C9"),
                Color(hex: "E8F5E9")
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}

#Preview {
    AnimatedGradientBackgroundView()
        .ignoresSafeArea()
}

