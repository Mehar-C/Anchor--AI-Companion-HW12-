import Foundation
import WatchConnectivity

class WatchConnectivityService: NSObject, ObservableObject {
    static let shared = WatchConnectivityService()
    
    @Published var stressAlertReceived = false
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendStressLevel(_ level: StressLevel) {
        guard WCSession.default.isReachable else { return }
        
        let message: [String: Any] = [
            "stressLevel": level.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message to watch: \(error.localizedDescription)")
        }
    }
}

extension WatchConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Reactivate session
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let stressAlert = message["stressAlert"] as? Bool, stressAlert {
            DispatchQueue.main.async {
                self.stressAlertReceived = true
            }
        }
    }
}

#if os(watchOS)
extension WatchConnectivityService {
    func sendStressAlert() {
        guard WCSession.default.isReachable else { return }
        
        let message: [String: Any] = [
            "stressAlert": true,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending stress alert: \(error.localizedDescription)")
        }
    }
}
#endif

