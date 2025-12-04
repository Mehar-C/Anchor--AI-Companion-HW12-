import SwiftUI

struct SessionSummaryView: View {
    let session: Session
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            if session.successful {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Great Job!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("You've earned 1 CalmToken")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Session Complete")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Keep practicing")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Session stats
            VStack(alignment: .leading, spacing: 8) {
                Text("Session Summary")
                    .font(.headline)
                
                HStack {
                    Text("Duration:")
                    Spacer()
                    Text(formatDuration(session.startTime, session.endTime ?? Date()))
                }
                
                HStack {
                    Text("Strategies Used:")
                    Spacer()
                    Text("\(session.copingStrategies.count)")
                }
                
                if let initialStress = session.stressLevels.first?.stress,
                   let finalStress = session.stressLevels.last?.stress {
                    HStack {
                        Text("Stress Reduction:")
                        Spacer()
                        Text("\(Int((initialStress - finalStress) * 100))%")
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.3))
            )
            
            Button("Done") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "E8F5E9"))
        )
    }
    
    private func formatDuration(_ start: Date, _ end: Date) -> String {
        let duration = end.timeIntervalSince(start)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    SessionSummaryView(
        session: Session(
            id: UUID(),
            startTime: Date().addingTimeInterval(-300),
            endTime: Date(),
            stressLevels: [],
            copingStrategies: [.breathingExercise],
            successful: true
        ),
        isPresented: .constant(true)
    )
    .environmentObject(AppState())
}

