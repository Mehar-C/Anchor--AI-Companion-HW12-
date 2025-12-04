import SwiftUI

@main
struct AnchorApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Debug: Print to console when app starts
        print("Anchor app starting...")
        
        // Load .env file at app startup
        EnvLoader.load()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    print("✅ AnchorApp: WindowGroup appeared")
                }
        }
    }
}

