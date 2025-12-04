import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isActive: Bool = false
    @Published var currentSession: Session?
    @Published var calmTokens: Int = 0
    @Published var streak: Int = 0
}

struct Session: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var stressLevels: [StressReading]
    var copingStrategies: [CopingStrategy]
    var successful: Bool = false
}

struct StressReading: Codable {
    let timestamp: Date
    let stress: Double // 0.0 - 1.0
    let breathing: Double // 0.0 - 1.0
    let engagement: Double // 0.0 - 1.0
}

enum CopingStrategy: String, Codable {
    case breathingExercise = "breathing_exercise"
    case cognitiveReframing = "cognitive_reframing"
    case microPlanning = "micro_planning"
    case grounding = "grounding"
    case mindfulness = "mindfulness"
}

