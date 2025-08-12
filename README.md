# 🛡️ DevAssist Security Monitor

**AI Security AI that Polices AI** - Complete multi-platform security monitoring solution with continuous threat detection, Siri voice alerts, SMS notifications, and Picture-in-Picture support.

## 🚀 Features

### 📱 iOS Application (`iOS/DevAssist-iOS/`)
- **Continuous Security Monitoring**: Real-time threat detection and analysis
- **Siri Integration**: Voice alerts using AVSpeechSynthesis
- **SMS Notifications**: Text message alerts via Twilio integration  
- **Picture-in-Picture (PiP)**: Apple's native PiP for off-screen monitoring
- **Background Processing**: Continues monitoring when app is in background
- **Native UI**: Clean, intuitive iOS interface with threat history

### 🖥️ macOS Application (`macOS/DevAssist-macOS/`)
- **AppKit Integration**: Native macOS desktop application
- **System-Level Monitoring**: Deep system integrity checks
- **Menu Bar Access**: Quick access to security status
- **macOS Notifications**: Native notification center integration
- **Voice Alerts**: macOS speech synthesis for threat announcements
- **Multi-Window Support**: Floating security monitor window

### 🔄 Continuous Monitor (`continuousSecurityMonitor.js`)
- **Real-Time Scanning**: Configurable interval-based security scans
- **Pattern Detection**: Advanced threat pattern recognition
- **Multi-Language Support**: Scans JavaScript, Python, Swift, C++, and more
- **Credential Detection**: Finds hardcoded passwords, API keys, secrets
- **Network Analysis**: Detects suspicious network patterns
- **Threat History**: Maintains detailed threat logs and analytics

## 📋 System Requirements

- **iOS**: iOS 15.0+ (iPhone/iPad)
- **macOS**: macOS 12.0+ (Intel/Apple Silicon)
- **Node.js**: v14+ for continuous monitoring
- **Xcode**: 14.0+ for building iOS/macOS apps
- **Twilio Account**: Optional, for SMS notifications

## 🛠️ Installation & Setup

### 1. Clone Repository
```bash
git clone https://github.com/DevAssist4-2-0/DevAssist4-2-0Aug1st2025.git
cd DevAssist4-2-0Aug1st2025
```

### 2. Install Dependencies
```bash
npm install uuid
```

### 3. Configure SMS Alerts (Optional)
Set environment variables for Twilio integration:
```bash
export TWILIO_SID="your_twilio_account_sid"
export TWILIO_TOKEN="your_twilio_auth_token" 
export TWILIO_FROM="+1234567890"
export TWILIO_TO="+0987654321"
```

### 4. Build & Test
```bash
./build-and-test.sh
```

## 🏃‍♂️ Quick Start

### Run Continuous Monitoring
```bash
# Start continuous monitoring (scans every 60 seconds)
node continuousSecurityMonitor.js start

# Start with custom interval (scans every 30 seconds)  
node continuousSecurityMonitor.js start 30

# Run single scan
node continuousSecurityMonitor.js scan

# Generate test alert
node continuousSecurityMonitor.js test
```

### Build iOS App
```bash
# Open in Xcode
open iOS/DevAssist-iOS/DevAssist-iOS.xcodeproj

# Or validate structure
./build-and-test.sh ios
```

### Build macOS App  
```bash
# Open in Xcode
open macOS/DevAssist-macOS/DevAssist-macOS.xcodeproj

# Or validate structure
./build-and-test.sh macos
```

## 🔍 Security Features

### Threat Detection
- **Suspicious Keywords**: Detects potentially malicious code patterns
- **Credential Exposure**: Finds hardcoded passwords, API keys, secrets
- **Code Injection**: Identifies eval(), exec(), shell execution patterns
- **Network Anomalies**: Detects suspicious URLs and connections
- **File Integrity**: Monitors unauthorized system file modifications

### Alert System
- **🗣️ Voice Alerts**: Siri/system speech synthesis
- **📱 SMS Notifications**: Twilio-powered text messages  
- **🔔 Push Notifications**: Native iOS/macOS notifications
- **📊 Visual Dashboard**: Real-time threat status display
- **📋 Threat History**: Detailed logs with timestamps and severity

### Picture-in-Picture (iOS)
- **Seamless Monitoring**: Security status follows you off-screen
- **Real-Time Updates**: Live threat count and status indicators
- **Tap to Restore**: Quick return to full app interface
- **Background Persistence**: Continues monitoring in PiP mode

## 📱 iOS App Usage

1. **Launch App**: Tap DevAssist icon to open
2. **Start Monitoring**: Tap "Start Monitoring" button
3. **Enable PiP**: Tap "Enable PiP" for off-screen monitoring
4. **View Threats**: Scroll through threat history table
5. **Test Alerts**: Use "Test Alert" to verify functionality

### iOS Permissions Required
- **Microphone**: For Siri speech synthesis
- **Background App Refresh**: For continuous monitoring
- **Notifications**: For alert delivery

## 🖥️ macOS App Usage

1. **Launch App**: Open DevAssist from Applications
2. **Monitor Status**: View real-time security status
3. **Start/Stop**: Control monitoring with toolbar buttons
4. **Threat Table**: Browse detected threats in sortable table
5. **Menu Bar**: Access quick status from menu bar (future feature)

### macOS Permissions Required
- **Microphone**: For voice alert synthesis
- **Network**: For SMS and threat reporting
- **File System**: For security scanning

## 🔧 Configuration

### Continuous Monitor Settings
Edit `continuousSecurityMonitor.js` to customize:
- Scan intervals (default: 60 seconds)
- Suspicious keywords list
- File type filters
- Threat severity levels
- Alert thresholds

### iOS/macOS App Settings  
Modify Info.plist files for:
- App permissions and descriptions
- Background modes
- PiP capabilities
- Notification preferences

## 🚨 Alert Types & Severity Levels

### Severity Levels
- **🚨 Critical**: Immediate security threats requiring urgent attention
- **🔥 High**: Significant security risks needing prompt response  
- **⚠️ Medium**: Moderate security concerns for investigation
- **ℹ️ Low**: Informational security notifications

### Alert Types
- **Suspicious Code Pattern**: Potentially malicious code detected
- **Credential Exposure**: Hardcoded secrets found in code
- **Network Anomaly**: Unusual network activity detected  
- **System Integrity**: Critical system file modifications
- **Process Anomaly**: Suspicious process behavior
- **Access Violation**: Unauthorized access attempts

## 🧪 Testing

### Run All Tests
```bash
./build-and-test.sh test
```

### Component Tests
```bash
./build-and-test.sh ios      # Test iOS project
./build-and-test.sh macos    # Test macOS project  
./build-and-test.sh monitor  # Test continuous monitor
./build-and-test.sh demo     # Run full demonstration
```

## 🔧 Troubleshooting

### Common Issues

**Speech Synthesis Not Working**
- Ensure microphone permissions are granted
- Check system speech synthesis settings
- Verify AVSpeechSynthesis availability

**SMS Alerts Not Sending**  
- Verify Twilio credentials are set correctly
- Check network connectivity
- Confirm phone number formatting (+1234567890)

**PiP Not Starting (iOS)**
- Ensure iOS 15.0+ device/simulator
- Check app permissions for background modes
- Verify PiPViewController configuration

**Build Errors (Xcode)**
- Update to latest Xcode version (14.0+)
- Check code signing settings
- Verify deployment target versions

## 🛡️ Security Best Practices

1. **Secure Credentials**: Never commit Twilio credentials to version control
2. **Regular Updates**: Keep dependencies and frameworks updated
3. **Permission Audits**: Regularly review app permissions
4. **Threat Analysis**: Investigate all high/critical severity alerts
5. **Backup Monitoring**: Use multiple monitoring approaches

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 📞 Support

For issues and support:
- 📧 Email: support@devassist.com
- 🐛 Issues: [GitHub Issues](https://github.com/DevAssist4-2-0/DevAssist4-2-0Aug1st2025/issues)
- 📖 Documentation: [Wiki](https://github.com/DevAssist4-2-0/DevAssist4-2-0Aug1st2025/wiki)

---

**🛡️ DevAssist Security Monitor** - *Protecting your development environment with intelligence and vigilance.*
