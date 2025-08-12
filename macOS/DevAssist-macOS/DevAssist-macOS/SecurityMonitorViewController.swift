import Cocoa

class SecurityMonitorViewController: NSViewController, SecurityMonitorDelegate {
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var threatTableView: NSTableView!
    @IBOutlet weak var threatCountLabel: NSTextField!
    @IBOutlet weak var lastScanLabel: NSTextField!
    @IBOutlet weak var testAlertButton: NSButton!
    @IBOutlet weak var scrollView: NSScrollView!
    
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
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        // Configure status label
        statusLabel?.stringValue = "Security Monitor Ready"
        statusLabel?.textColor = NSColor.labelColor
        statusLabel?.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        
        // Configure buttons
        configureButtons()
        
        // Setup labels
        updateStatusLabels()
    }
    
    private func configureButtons() {
        // Start/Stop button
        startStopButton?.title = "Start Monitoring"
        startStopButton?.bezelStyle = .rounded
        startStopButton?.controlSize = .large
        
        // Test alert button
        testAlertButton?.title = "Generate Test Alert"
        testAlertButton?.bezelStyle = .rounded
        testAlertButton?.controlSize = .regular
    }
    
    private func setupSecurityMonitor() {
        securityMonitor.delegate = self
    }
    
    private func setupTableView() {
        // Configure table view
        threatTableView?.delegate = self
        threatTableView?.dataSource = self
        threatTableView?.usesAlternatingRowBackgroundColors = true
        threatTableView?.allowsMultipleSelection = false
        threatTableView?.intercellSpacing = NSSize(width: 3, height: 2)
        
        // Setup columns
        setupTableColumns()
        
        // Configure scroll view
        scrollView?.hasVerticalScroller = true
        scrollView?.hasHorizontalScroller = false
        scrollView?.autohidesScrollers = true
    }
    
    private func setupTableColumns() {
        // Clear existing columns
        while threatTableView.tableColumns.count > 0 {
            threatTableView.removeTableColumn(threatTableView.tableColumns[0])
        }
        
        // Severity column
        let severityColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("severity"))
        severityColumn.title = "Severity"
        severityColumn.width = 80
        severityColumn.minWidth = 60
        severityColumn.maxWidth = 100
        threatTableView.addTableColumn(severityColumn)
        
        // Type column
        let typeColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("type"))
        typeColumn.title = "Type"
        typeColumn.width = 150
        typeColumn.minWidth = 100
        typeColumn.maxWidth = 200
        threatTableView.addTableColumn(typeColumn)
        
        // Message column
        let messageColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("message"))
        messageColumn.title = "Message"
        messageColumn.width = 300
        messageColumn.minWidth = 200
        threatTableView.addTableColumn(messageColumn)
        
        // Time column
        let timeColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("time"))
        timeColumn.title = "Time"
        timeColumn.width = 120
        timeColumn.minWidth = 100
        timeColumn.maxWidth = 150
        threatTableView.addTableColumn(timeColumn)
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
                self.statusLabel?.stringValue = "🟢 Security Monitor Active"
                self.statusLabel?.textColor = NSColor.systemGreen
                self.startStopButton?.title = "Stop Monitoring"
            } else {
                self.statusLabel?.stringValue = "🔴 Security Monitor Inactive"
                self.statusLabel?.textColor = NSColor.systemRed
                self.startStopButton?.title = "Start Monitoring"
            }
            
            self.threatCountLabel?.stringValue = "Threats Detected: \(self.securityMonitor.threats.count)"
            self.lastScanLabel?.stringValue = "Last Update: \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))"
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func startStopButtonClicked(_ sender: NSButton) {
        if securityMonitor.isActive {
            securityMonitor.stopMonitoring()
            showAlert(title: "Monitoring Stopped", message: "Security monitoring has been deactivated.")
        } else {
            securityMonitor.startContinuousMonitoring()
            showAlert(title: "Monitoring Started", message: "Continuous security monitoring is now active on your Mac.")
        }
        updateStatusLabels()
    }
    
    @IBAction func testAlertButtonClicked(_ sender: NSButton) {
        securityMonitor.generateTestThreat()
        showAlert(title: "Test Alert Generated", message: "A test security threat has been generated to verify system functionality.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    // MARK: - SecurityMonitorDelegate
    
    func securityThreatDetected(_ threat: SecurityThreat) {
        DispatchQueue.main.async {
            // Show urgent alert for high/critical threats
            if threat.severity == .high || threat.severity == .critical {
                let alert = NSAlert()
                alert.messageText = "🚨 Security Alert"
                alert.informativeText = "[\(threat.severity.rawValue)] \(threat.type)\n\n\(threat.message)"
                alert.alertStyle = .critical
                alert.addButton(withTitle: "Acknowledged")
                alert.runModal()
            }
            
            // Reload table to show new threat
            self.threatTableView?.reloadData()
            self.updateStatusLabels()
            
            // Scroll to top to show latest threat
            if !self.securityMonitor.threats.isEmpty {
                self.threatTableView?.scrollRowToVisible(0)
            }
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}

// MARK: - NSTableViewDataSource & NSTableViewDelegate

extension SecurityMonitorViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return securityMonitor.threats.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let threats = securityMonitor.threats.reversed() // Show newest first
        let threat = Array(threats)[row]
        
        guard let identifier = tableColumn?.identifier else { return nil }
        
        let cellView = NSTableCellView()
        let textField = NSTextField()
        textField.isBordered = false
        textField.isEditable = false
        textField.backgroundColor = NSColor.clear
        
        switch identifier.rawValue {
        case "severity":
            let severityIcon: String
            let severityColor: NSColor
            
            switch threat.severity {
            case .low:
                severityIcon = "ℹ️"
                severityColor = NSColor.systemBlue
            case .medium:
                severityIcon = "⚠️"
                severityColor = NSColor.systemOrange
            case .high:
                severityIcon = "🔥"
                severityColor = NSColor.systemRed
            case .critical:
                severityIcon = "🚨"
                severityColor = NSColor.systemPurple
            }
            
            textField.stringValue = "\(severityIcon) \(threat.severity.rawValue)"
            textField.textColor = severityColor
            textField.font = NSFont.systemFont(ofSize: 12, weight: .semibold)
            
        case "type":
            textField.stringValue = threat.type
            textField.textColor = NSColor.labelColor
            textField.font = NSFont.systemFont(ofSize: 12, weight: .medium)
            
        case "message":
            textField.stringValue = threat.message
            textField.textColor = NSColor.labelColor
            textField.font = NSFont.systemFont(ofSize: 11)
            textField.usesSingleLineMode = false
            textField.maximumNumberOfLines = 3
            textField.cell?.wraps = true
            
        case "time":
            let timeString = DateFormatter.localizedString(from: threat.timestamp, dateStyle: .none, timeStyle: .medium)
            textField.stringValue = timeString
            textField.textColor = NSColor.secondaryLabelColor
            textField.font = NSFont.systemFont(ofSize: 10)
            
        default:
            textField.stringValue = ""
        }
        
        cellView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 5),
            textField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -5),
            textField.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 2),
            textField.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -2)
        ])
        
        cellView.textField = textField
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40 // Fixed row height for consistent appearance
    }
}