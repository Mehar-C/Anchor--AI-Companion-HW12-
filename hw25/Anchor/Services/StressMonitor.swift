import Foundation
import Combine

class StressMonitor: ObservableObject {
    @Published var currentStressLevel: StressLevel = .calm
    @Published var readings: [StressReading] = []
    
    private let presageService = PresageService()
    private var cancellables = Set<AnyCancellable>()
    
    func startMonitoring() {
        presageService.startCapture()
        
        presageService.$currentReading
            .compactMap { $0 }
            .sink { [weak self] reading in
                self?.processReading(reading)
            }
            .store(in: &cancellables)
    }
    
    func stopMonitoring() {
        presageService.stopCapture()
    }
    
    private func processReading(_ reading: StressReading) {
        readings.append(reading)
        
        // Keep only last 60 seconds of readings
        let cutoff = Date().addingTimeInterval(-60)
        readings = readings.filter { $0.timestamp > cutoff }
        
        // Calculate current stress level
        let recentReadings = readings.suffix(10)
        let avgStress = recentReadings.map { $0.stress }.reduce(0, +) / Double(recentReadings.count)
        
        let newLevel: StressLevel
        if avgStress < 0.3 {
            newLevel = .calm
        } else if avgStress < 0.7 {
            newLevel = .rising
        } else {
            newLevel = .spiking
        }
        
        if newLevel != currentStressLevel {
            currentStressLevel = newLevel
        }
    }
    
    func hasDeEscalated() -> Bool {
        guard readings.count >= 20 else { return false }
        
        let firstHalf = Array(readings.prefix(10))
        let secondHalf = Array(readings.suffix(10))
        
        let firstAvg = firstHalf.map { $0.stress }.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.map { $0.stress }.reduce(0, +) / Double(secondHalf.count)
        
        // De-escalated if stress reduced by at least 30%
        return secondAvg < firstAvg * 0.7
    }
}

