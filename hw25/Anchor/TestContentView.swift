import SwiftUI

// Simple test view to debug black screen
struct TestContentView: View {
    var body: some View {
        ZStack {
            // Simple background
            Color.green.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                Text("Anchor App")
                    .font(.largeTitle)
                    .padding()
                
                Text("If you see this, the app is working!")
                    .font(.headline)
                    .padding()
                
                Text("The black screen was likely a camera initialization issue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

#Preview {
    TestContentView()
}

