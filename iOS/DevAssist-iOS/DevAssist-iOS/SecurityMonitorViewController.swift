import UIKit

class SecurityMonitorViewController: UIViewController, SecurityMonitorDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var threatTableView: UITableView!
    @IBOutlet weak var threatCountLabel: UILabel!
    @IBOutlet weak var lastScanLabel: UILabel!
    @IBOutlet weak var pipButton: UIButton!
    @IBOutlet weak var testAlertButton: UIButton!
    
    private let securityMonitor = SecurityMonitor.shared
    private var refreshTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSecurityMonitor()
        setupTableView()
        startRefreshTimer()
    }
    
    private func setupUI() {
        title = "🛡️ DevAssist Security Monitor"
        view.backgroundColor = UIColor.systemBackground
        
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup status label
        statusLabel?.text = "Security Monitor Ready"
        statusLabel?.textColor = UIColor.label
        statusLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // Setup buttons
        configureButtons()
        
        // Setup threat count and last scan labels
        updateStatusLabels()
    }
    
    private func configureButtons() {
        // Start/Stop button configuration
        startStopButton?.backgroundColor = UIColor.systemGreen
        startStopButton?.setTitleColor(UIColor.white, for: .normal)
        startStopButton?.layer.cornerRadius = 8
        startStopButton?.setTitle("Start Monitoring", for: .normal)
        
        // PiP button configuration
        pipButton?.backgroundColor = UIColor.systemBlue
        pipButton?.setTitleColor(UIColor.white, for: .normal)
        pipButton?.layer.cornerRadius = 8
        pipButton?.setTitle("Enable PiP", for: .normal)
        
        // Test alert button configuration
        testAlertButton?.backgroundColor = UIColor.systemOrange
        testAlertButton?.setTitleColor(UIColor.white, for: .normal)
        testAlertButton?.layer.cornerRadius = 8
        testAlertButton?.setTitle("Test Alert", for: .normal)
    }
    
    private func setupSecurityMonitor() {
        securityMonitor.delegate = self
    }
    
    private func setupTableView() {
        threatTableView?.delegate = self
        threatTableView?.dataSource = self
        threatTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "ThreatCell")
        threatTableView?.separatorStyle = .singleLine
        threatTableView?.backgroundColor = UIColor.systemBackground
    }
    
    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateStatusLabels()
            self?.threatTableView?.reloadData()
        }
    }
    
    private func updateStatusLabels() {
        DispatchQueue.main.async {
            if self.securityMonitor.isActive {
                self.statusLabel?.text = "🟢 Security Monitor Active"
                self.statusLabel?.textColor = UIColor.systemGreen
                self.startStopButton?.setTitle("Stop Monitoring", for: .normal)
                self.startStopButton?.backgroundColor = UIColor.systemRed
            } else {
                self.statusLabel?.text = "🔴 Security Monitor Inactive"
                self.statusLabel?.textColor = UIColor.systemRed
                self.startStopButton?.setTitle("Start Monitoring", for: .normal)
                self.startStopButton?.backgroundColor = UIColor.systemGreen
            }
            
            self.threatCountLabel?.text = "Threats Detected: \(self.securityMonitor.threats.count)"
            self.lastScanLabel?.text = "Last Update: \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))"
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func startStopButtonTapped(_ sender: UIButton) {
        if securityMonitor.isActive {
            securityMonitor.stopMonitoring()
            showAlert(title: "Monitoring Stopped", message: "Security monitoring has been deactivated.")
        } else {
            securityMonitor.startContinuousMonitoring()
            showAlert(title: "Monitoring Started", message: "Continuous security monitoring is now active.")
        }
        updateStatusLabels()
    }
    
    @IBAction func pipButtonTapped(_ sender: UIButton) {
        PiPViewController.shared.startPictureInPicture()
        showAlert(title: "Picture-in-Picture", message: "PiP mode enabled. Security monitor will continue when you leave the app.")
    }
    
    @IBAction func testAlertButtonTapped(_ sender: UIButton) {
        securityMonitor.generateTestThreat()
        showAlert(title: "Test Alert", message: "A test security threat has been generated.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - SecurityMonitorDelegate
    
    func securityThreatDetected(_ threat: SecurityThreat) {
        DispatchQueue.main.async {
            // Show urgent alert for high/critical threats
            if threat.severity == .high || threat.severity == .critical {
                let alert = UIAlertController(
                    title: "🚨 Security Alert",
                    message: "[\(threat.severity.rawValue)] \(threat.type)\n\n\(threat.message)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Acknowledged", style: .default))
                self.present(alert, animated: true)
            }
            
            // Reload table to show new threat
            self.threatTableView?.reloadData()
            self.updateStatusLabels()
            
            // Scroll to top to show latest threat
            if !self.securityMonitor.threats.isEmpty {
                self.threatTableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SecurityMonitorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return securityMonitor.threats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreatCell", for: indexPath)
        
        let threats = securityMonitor.threats.reversed() // Show newest first
        let threat = Array(threats)[indexPath.row]
        
        // Configure cell appearance based on severity
        let severityColor: UIColor
        let severityIcon: String
        
        switch threat.severity {
        case .low:
            severityColor = UIColor.systemBlue
            severityIcon = "ℹ️"
        case .medium:
            severityColor = UIColor.systemOrange
            severityIcon = "⚠️"
        case .high:
            severityColor = UIColor.systemRed
            severityIcon = "🔥"
        case .critical:
            severityColor = UIColor.systemPurple
            severityIcon = "🚨"
        }
        
        let timeString = DateFormatter.localizedString(from: threat.timestamp, dateStyle: .none, timeStyle: .medium)
        
        // Create attributed text
        let attributedText = NSMutableAttributedString()
        
        // Severity and type
        let titleText = NSAttributedString(
            string: "\(severityIcon) [\(threat.severity.rawValue)] \(threat.type)\n",
            attributes: [
                .foregroundColor: severityColor,
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
            ]
        )
        attributedText.append(titleText)
        
        // Message
        let messageText = NSAttributedString(
            string: "\(threat.message)\n",
            attributes: [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )
        attributedText.append(messageText)
        
        // Timestamp
        let timeText = NSAttributedString(
            string: timeString,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: 12)
            ]
        )
        attributedText.append(timeText)
        
        cell.textLabel?.attributedText = attributedText
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = UIColor.systemBackground
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return securityMonitor.threats.isEmpty ? "No threats detected" : "Recent Security Threats"
    }
}