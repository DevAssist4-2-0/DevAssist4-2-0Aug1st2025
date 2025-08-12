import UIKit
import AVSpeechSynthesis
import MessageUI

protocol SecurityMonitorDelegate: AnyObject {
    func securityThreatDetected(_ threat: SecurityThreat)
}

struct SecurityThreat {
    let type: String
    let severity: SeverityLevel
    let message: String
    let timestamp: Date
}

enum SeverityLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

class SecurityMonitor: NSObject, ObservableObject {
    static let shared = SecurityMonitor()
    
    weak var delegate: SecurityMonitorDelegate?
    private var monitoringTimer: Timer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var isMonitoring = false
    
    // Twilio configuration (should be set from environment or config)
    private var twilioSID: String = ""
    private var twilioToken: String = ""
    private var twilioFromNumber: String = ""
    private var twilioToNumber: String = ""
    
    @Published var threats: [SecurityThreat] = []
    @Published var isActive = false
    
    override init() {
        super.init()
        loadTwilioConfiguration()
    }
    
    private func loadTwilioConfiguration() {
        // Load from environment or configuration file
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) {
            twilioSID = config["TWILIO_SID"] as? String ?? ""
            twilioToken = config["TWILIO_TOKEN"] as? String ?? ""
            twilioFromNumber = config["TWILIO_FROM"] as? String ?? ""
            twilioToNumber = config["TWILIO_TO"] as? String ?? ""
        }
    }
    
    func startContinuousMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        isActive = true
        
        // Start monitoring timer - check every 30 seconds
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.performSecurityScan()
        }
        
        print("🛡️ Security monitoring started")
        speakAlert("Security monitoring activated. DevAssist is now watching for threats.")
    }
    
    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        isMonitoring = false
        isActive = false
        
        print("🛡️ Security monitoring stopped")
        speakAlert("Security monitoring deactivated.")
    }
    
    private func performSecurityScan() {
        // Simulate security scanning - in reality this would check:
        // - Network activity
        // - File system changes
        // - Process monitoring
        // - Memory analysis
        // - Certificate validation
        
        let suspiciousActivities = checkForSuspiciousActivity()
        
        for activity in suspiciousActivities {
            let threat = SecurityThreat(
                type: activity.type,
                severity: activity.severity,
                message: activity.message,
                timestamp: Date()
            )
            
            DispatchQueue.main.async {
                self.threats.append(threat)
                self.delegate?.securityThreatDetected(threat)
                self.handleThreatDetection(threat)
            }
        }
    }
    
    private func checkForSuspiciousActivity() -> [SecurityThreat] {
        var threats: [SecurityThreat] = []
        
        // Check for unusual network activity
        if arc4random_uniform(100) < 15 { // 15% chance for demo
            threats.append(SecurityThreat(
                type: "Network Anomaly",
                severity: .medium,
                message: "Unusual outbound network connection detected to unknown server",
                timestamp: Date()
            ))
        }
        
        // Check for unauthorized access attempts
        if arc4random_uniform(100) < 8 { // 8% chance for demo
            threats.append(SecurityThreat(
                type: "Access Violation",
                severity: .high,
                message: "Unauthorized access attempt to secure resources detected",
                timestamp: Date()
            ))
        }
        
        // Check for malicious code signatures
        if arc4random_uniform(100) < 5 { // 5% chance for demo
            threats.append(SecurityThreat(
                type: "Malicious Code",
                severity: .critical,
                message: "Potentially malicious code signature detected in system processes",
                timestamp: Date()
            ))
        }
        
        return threats
    }
    
    private func handleThreatDetection(_ threat: SecurityThreat) {
        // Speak the alert
        let alertMessage = "Security threat detected: \(threat.type). Severity level: \(threat.severity.rawValue). \(threat.message)"
        speakAlert(alertMessage)
        
        // Send SMS notification
        sendSMSAlert(threat)
        
        // Log the threat
        print("🚨 THREAT DETECTED: [\(threat.severity.rawValue)] \(threat.type) - \(threat.message)")
    }
    
    private func speakAlert(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.2
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
    
    private func sendSMSAlert(_ threat: SecurityThreat) {
        guard !twilioSID.isEmpty,
              !twilioToken.isEmpty,
              !twilioFromNumber.isEmpty,
              !twilioToNumber.isEmpty else {
            print("⚠️ Twilio configuration incomplete. SMS alerts disabled.")
            return
        }
        
        let message = "🚨 DevAssist Security Alert: [\(threat.severity.rawValue)] \(threat.type) detected at \(DateFormatter.localizedString(from: threat.timestamp, dateStyle: .short, timeStyle: .medium)). \(threat.message)"
        
        let urlString = "https://api.twilio.com/2010-04-01/Accounts/\(twilioSID)/Messages.json"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let credentials = "\(twilioSID):\(twilioToken)".data(using: .utf8)?.base64EncodedString() ?? ""
        request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyData = "From=\(twilioFromNumber)&To=\(twilioToNumber)&Body=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = bodyData.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ SMS sending failed: \(error.localizedDescription)")
            } else {
                print("✅ SMS alert sent successfully")
            }
        }.resume()
    }
    
    func generateTestThreat() {
        let testThreat = SecurityThreat(
            type: "Test Alert",
            severity: .medium,
            message: "This is a test security alert to verify system functionality",
            timestamp: Date()
        )
        
        threats.append(testThreat)
        handleThreatDetection(testThreat)
    }
}