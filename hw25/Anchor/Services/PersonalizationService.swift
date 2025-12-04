import Foundation

class PersonalizationService {
    private let apiKey: String
    private let baseURL: String
    private var userHistory: [StrategyEffectiveness] = []
    
    init(apiKey: String = Config.gradientAPIKey, baseURL: String = Config.gradientBaseURL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    func recommendStrategy(
        stressLevel: StressLevel,
        recentReadings: [StressReading]
    ) async -> CopingStrategy? {
        // Load user history
        await loadUserHistory()
        
        // Use Gradient AI to predict best strategy
        let recommendation = await queryGradientModel(
            stressLevel: stressLevel,
            recentReadings: recentReadings,
            history: userHistory
        )
        
        return recommendation
    }
    
    func recordStrategyEffectiveness(
        strategy: CopingStrategy,
        initialStress: Double,
        finalStress: Double
    ) async {
        let effectiveness = StrategyEffectiveness(
            strategy: strategy,
            stressReduction: initialStress - finalStress,
            timestamp: Date()
        )
        
        userHistory.append(effectiveness)
        await saveUserHistory()
        await updateGradientModel(effectiveness)
    }
    
    private func queryGradientModel(
        stressLevel: StressLevel,
        recentReadings: [StressReading],
        history: [StrategyEffectiveness]
    ) async -> CopingStrategy? {
        // TODO: Implement actual Gradient AI API call
        // This would send user history and current state to the model
        
        // For now, return a simple recommendation based on stress level
        switch stressLevel {
        case .calm:
            return .mindfulness
        case .rising:
            return .breathingExercise
        case .spiking:
            return .grounding
        }
    }
    
    private func updateGradientModel(_ effectiveness: StrategyEffectiveness) async {
        // TODO: Fine-tune or update the Gradient AI model with new data
    }
    
    private func loadUserHistory() async {
        // Load from UserDefaults or local storage
        if let data = UserDefaults.standard.data(forKey: "strategyHistory"),
           let history = try? JSONDecoder().decode([StrategyEffectiveness].self, from: data) {
            userHistory = history
        }
    }
    
    private func saveUserHistory() async {
        if let data = try? JSONEncoder().encode(userHistory) {
            UserDefaults.standard.set(data, forKey: "strategyHistory")
        }
    }
}

struct StrategyEffectiveness: Codable {
    let strategy: CopingStrategy
    let stressReduction: Double
    let timestamp: Date
}

