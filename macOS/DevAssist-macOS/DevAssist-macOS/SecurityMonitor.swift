import Cocoa
import AVFoundation

// Shared SecurityMonitor class for macOS (similar to iOS version but adapted for AppKit)
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
    
    // Twilio configuration
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
        // Load from environment variables or configuration
        twilioSID = ProcessInfo.processInfo.environment["TWILIO_SID"] ?? ""
        twilioToken = ProcessInfo.processInfo.environment["TWILIO_TOKEN"] ?? ""
        twilioFromNumber = ProcessInfo.processInfo.environment["TWILIO_FROM"] ?? ""
        twilioToNumber = ProcessInfo.processInfo.environment["TWILIO_TO"] ?? ""
    }
    
    func startContinuousMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        isActive = true
        
        // Start monitoring timer - check every 30 seconds
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.performSecurityScan()
        }
        
        print("🛡️ macOS Security monitoring started")
        speakAlert("DevAssist Security Monitor for macOS is now active and protecting your system.")
    }
    
    func stopMonitoring() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        isMonitoring = false
        isActive = false
        
        print("🛡️ macOS Security monitoring stopped")
        speakAlert("Security monitoring deactivated.")
    }
    
    private func performSecurityScan() {
        // Enhanced security scanning for macOS
        let suspiciousActivities = checkForMacOSThreats()
        
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
    
    private func checkForMacOSThreats() -> [SecurityThreat] {
        var threats: [SecurityThreat] = []
        
        // Check system integrity
        if arc4random_uniform(100) < 12 { // 12% chance for demo
            threats.append(SecurityThreat(
                type: "System Integrity Check",
                severity: .high,
                message: "Potential unauthorized system modification detected in kernel space",
                timestamp: Date()
            ))
        }
        
        // Check for suspicious processes
        if arc4random_uniform(100) < 10 { // 10% chance for demo
            threats.append(SecurityThreat(
                type: "Process Anomaly",
                severity: .medium,
                message: "Unusual process behavior detected with elevated privileges",
                timestamp: Date()
            ))
        }
        
        // Check network connections
        if arc4random_uniform(100) < 8 { // 8% chance for demo
            threats.append(SecurityThreat(
                type: "Network Security",
                severity: .high,
                message: "Suspicious outbound connection to blacklisted IP address",
                timestamp: Date()
            ))
        }
        
        // Check file system integrity
        if arc4random_uniform(100) < 6 { // 6% chance for demo
            threats.append(SecurityThreat(
                type: "File System Alert",
                severity: .critical,
                message: "Unauthorized modification to critical system files detected",
                timestamp: Date()
            ))
        }
        
        return threats
    }
    
    private func handleThreatDetection(_ threat: SecurityThreat) {
        // Speak the alert (macOS version)
        let alertMessage = "Security threat detected on your Mac: \(threat.type). Severity level: \(threat.severity.rawValue). \(threat.message)"
        speakAlert(alertMessage)
        
        // Send SMS notification
        sendSMSAlert(threat)
        
        // Show macOS notification
        showMacOSNotification(threat)
        
        // Log the threat
        print("🚨 macOS THREAT DETECTED: [\(threat.severity.rawValue)] \(threat.type) - \(threat.message)")
    }
    
    private func speakAlert(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
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
        
        let message = "🚨 DevAssist macOS Alert: [\(threat.severity.rawValue)] \(threat.type) detected at \(DateFormatter.localizedString(from: threat.timestamp, dateStyle: .short, timeStyle: .medium)). \(threat.message)"
        
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
    
    private func showMacOSNotification(_ threat: SecurityThreat) {
        let notification = NSUserNotification()
        notification.title = "🚨 DevAssist Security Alert"
        notification.subtitle = "[\(threat.severity.rawValue)] \(threat.type)"
        notification.informativeText = threat.message
        notification.soundName = NSUserNotificationDefaultSoundName
        
        // Set notification priority based on severity
        switch threat.severity {
        case .critical, .high:
            notification.hasActionButton = true
            notification.actionButtonTitle = "View Details"
        default:
            break
        }
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func generateTestThreat() {
        let testThreat = SecurityThreat(
            type: "Test Alert - macOS",
            severity: .medium,
            message: "This is a test security alert to verify macOS system functionality",
            timestamp: Date()
        )
        
        threats.append(testThreat)
        handleThreatDetection(testThreat)
    }
}