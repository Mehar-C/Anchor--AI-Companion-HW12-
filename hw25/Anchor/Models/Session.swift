import Foundation

// Moved Session to separate file for better organization
// This is a duplicate - the original is in AppState.swift
// In a real project, you'd consolidate these

extension Session {
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var averageStress: Double {
        guard !stressLevels.isEmpty else { return 0.0 }
        return stressLevels.map { $0.stress }.reduce(0, +) / Double(stressLevels.count)
    }
}

