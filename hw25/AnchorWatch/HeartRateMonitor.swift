import Foundation
import HealthKit
import Combine

class HeartRateMonitor: ObservableObject {
    @Published var currentHeartRate: Double = 72.0
    @Published var stressDetected: Bool = false
    
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    
    private let restingHeartRate: Double = 72.0
    private let stressThreshold: Double = 100.0 // BPM threshold for stress
    
    func startMonitoring() {
        // Request authorization
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            if success {
                self?.startHeartRateQuery()
            } else {
                // For hackathon simulation, use mock data
                self?.simulateHeartRate()
            }
        }
    }
    
    private func startHeartRateQuery() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        healthStore.execute(query)
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        
        if let mostRecent = samples.last {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let heartRate = mostRecent.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                self.currentHeartRate = heartRate
                self.checkForStress(heartRate: heartRate)
            }
        }
    }
    
    private func simulateHeartRate() {
        // Simulate heart rate for hackathon demo
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                // Simulate occasional stress spikes
                let baseRate = Double.random(in: 65...85)
                let stressSpike = Bool.random() && Bool.random() // 25% chance
                let heartRate = stressSpike ? Double.random(in: 100...120) : baseRate
                
                self?.currentHeartRate = heartRate
                self?.checkForStress(heartRate: heartRate)
            }
            .store(in: &cancellables)
    }
    
    private func checkForStress(heartRate: Double) {
        // Detect stress if heart rate is significantly above resting rate
        let stressLevel = heartRate > stressThreshold
        
        if stressLevel && !stressDetected {
            // Trigger stress detection
            stressDetected = true
            
            // Auto-reset after 30 seconds if no further spikes
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                if self.currentHeartRate < self.stressThreshold {
                    self.stressDetected = false
                }
            }
        } else if !stressLevel {
            stressDetected = false
        }
    }
}

