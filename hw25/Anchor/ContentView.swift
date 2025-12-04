import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var stressMonitor = StressMonitor()
    @StateObject private var conversationManager = ConversationManager()
    @StateObject private var watchConnectivity = WatchConnectivityService.shared
    @State private var showSessionSummary = false
    @State private var completedSession: Session?
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Enhanced calming gradient background
            Theme.Colors.calmingGradient
                .ignoresSafeArea()
                .zIndex(-1)
            
            // Main content - ScrollView for interactivity
            ScrollView {
                VStack(spacing: Theme.Layout.padding) {
                    // Header with app name
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Anchor")
                                .font(Theme.Typography.header())
                                .foregroundStyle(Theme.Colors.primaryGradient)
                            Text("Your calm companion")
                                .font(Theme.Typography.caption())
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        
                        // Streaks or Tokens could go here
                    }
                    .padding(.horizontal, Theme.Layout.padding)
                    .padding(.top, 8)
                    
                    // Stress level indicator with animation
                    StressIndicatorView(stressLevel: stressMonitor.currentStressLevel)
                        .padding(.horizontal, Theme.Layout.padding)
                        .glassCard()
                        .padding(.horizontal, Theme.Layout.padding)
                    
                    // Camera preview for Presage with toggle
                    CameraPreviewView()
                        .environmentObject(stressMonitor)
                        .padding(.horizontal, Theme.Layout.padding)
                    
                    // Conversation interface
                    ConversationView()
                        .environmentObject(conversationManager)
                        .environmentObject(stressMonitor)
                        .padding(.horizontal, Theme.Layout.padding)
                    
                    // End session button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        endSession()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("End Session")
                                .font(Theme.Typography.subheader())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
                        .shadow(color: Theme.Colors.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, Theme.Layout.padding)
                    .padding(.bottom, 30)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            print("ContentView onAppear called")
            // Don't auto-start monitoring - let user control it via toggle button
            // Send stress level updates to watch when they change
            stressMonitor.$currentStressLevel
                .sink { level in
                    watchConnectivity.sendStressLevel(level)
                }
                .store(in: &cancellables)
        }
        .sheet(isPresented: $showSessionSummary) {
            if let session = completedSession {
                SessionSummaryView(session: session, isPresented: $showSessionSummary)
                    .environmentObject(appState)
            }
        }
    }
    
    private func endSession() {
        let hasDeEscalated = stressMonitor.hasDeEscalated()
        let finalReading = stressMonitor.readings.last ?? StressReading(
            timestamp: Date(),
            stress: 0.5,
            breathing: 0.5,
            engagement: 0.5
        )
        
        Task {
            await conversationManager.endSession(
                hasDeEscalated: hasDeEscalated,
                finalReading: finalReading
            )
            
            if let session = conversationManager.currentSession {
                completedSession = session
                await MainActor.run {
                    showSessionSummary = true
                    if hasDeEscalated {
                        appState.calmTokens += 1
                        appState.streak += 1
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

