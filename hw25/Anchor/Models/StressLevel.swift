import Foundation

enum StressLevel: String, CaseIterable {
    case calm = "calm"
    case rising = "rising"
    case spiking = "spiking"
    
    var color: String {
        switch self {
        case .calm: return "4CAF50"
        case .rising: return "FF9800"
        case .spiking: return "F44336"
        }
    }
    
    var description: String {
        switch self {
        case .calm: return "You're doing well"
        case .rising: return "Let's take a moment"
        case .spiking: return "I'm here with you"
        }
    }
}

