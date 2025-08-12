const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Enhanced security scanner with continuous monitoring
class ContinuousSecurityMonitor {
  constructor() {
    this.monitoringInterval = null;
    this.isMonitoring = false;
    this.suspiciousKeywords = [
      'google',
      'firebase',
      'gemini',
      'meta',
      'genai',
      'azure',
      'vertex',
      'replit',
      'googleapis',
      'gcp',
      'aws',
      'openai',
      'anthropic',
      'malware',
      'backdoor',
      'keylogger',
      'rootkit',
      'trojam',
      'virus'
    ];
    
    this.ignoredDirs = [
      'node_modules',
      '.git',
      'dist',
      'build',
      '__pycache__',
      '.DS_Store',
      'iOS',
      'macOS'
    ];
    
    this.threatHistory = [];
    this.scanCount = 0;
  }
  
  startContinuousMonitoring(intervalSeconds = 60) {
    if (this.isMonitoring) {
      console.log('🛡️  Monitoring is already active');
      return;
    }
    
    this.isMonitoring = true;
    console.log(`🛡️  Starting continuous security monitoring (every ${intervalSeconds}s)`);
    this.speakAlert('Continuous security monitoring activated for your development environment');
    
    // Initial scan
    this.performScan();
    
    // Set up continuous monitoring
    this.monitoringInterval = setInterval(() => {
      this.performScan();
    }, intervalSeconds * 1000);
  }
  
  stopMonitoring() {
    if (!this.isMonitoring) {
      console.log('🛡️  Monitoring is not active');
      return;
    }
    
    this.isMonitoring = false;
    if (this.monitoringInterval) {
      clearInterval(this.monitoringInterval);
      this.monitoringInterval = null;
    }
    
    console.log('🛡️  Security monitoring stopped');
    this.speakAlert('Security monitoring deactivated');
  }
  
  performScan() {
    this.scanCount++;
    const timestamp = new Date().toISOString();
    console.log(`\n🔍 Performing security scan #${this.scanCount} at ${timestamp}`);
    
    // Get target directory from command line args
    let targetDir = process.argv[2] || '.';
    // If called from within the script, use current directory
    if (targetDir === 'scan') {
      targetDir = '.';
    }
    const threats = this.scanDirectory(targetDir);
    
    if (threats.length > 0) {
      this.handleThreats(threats);
    } else {
      console.log('✅ No new threats detected in this scan');
    }
  }
  
  scanDirectory(dir) {
    const threats = [];
    
    try {
      const files = fs.readdirSync(dir);
      
      for (const file of files) {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
          if (!this.ignoredDirs.includes(file)) {
            threats.push(...this.scanDirectory(fullPath));
          }
        } else if (this.isScanableFile(fullPath)) {
          threats.push(...this.scanFile(fullPath));
        }
      }
    } catch (error) {
      console.error(`❌ Error scanning directory ${dir}:`, error.message);
    }
    
    return threats;
  }
  
  isScanableFile(filePath) {
    const extensions = ['.js', '.ts', '.json', '.py', '.swift', '.m', '.h', '.cpp', '.c', '.java', '.php', '.rb', '.go', '.rs'];
    return extensions.some(ext => filePath.endsWith(ext));
  }
  
  scanFile(filePath) {
    const threats = [];
    
    try {
      const content = fs.readFileSync(filePath, 'utf8').toLowerCase();
      
      this.suspiciousKeywords.forEach((keyword) => {
        if (content.includes(keyword)) {
          const threat = {
            id: uuidv4(),
            type: 'Suspicious Code Pattern',
            severity: this.getSeverityForKeyword(keyword),
            file: filePath,
            keyword: keyword,
            message: `Potentially suspicious keyword "${keyword}" found`,
            timestamp: new Date().toISOString(),
            scanId: this.scanCount
          };
          
          // Check if this is a new threat (not seen in recent scans)
          if (!this.isDuplicateThreat(threat)) {
            threats.push(threat);
          }
        }
      });
      
      // Additional security checks
      threats.push(...this.performAdvancedSecurityChecks(filePath, content));
      
    } catch (error) {
      console.error(`❌ Error scanning file ${filePath}:`, error.message);
    }
    
    return threats;
  }
  
  getSeverityForKeyword(keyword) {
    const highRiskKeywords = ['malware', 'backdoor', 'keylogger', 'rootkit', 'trojan', 'virus'];
    const mediumRiskKeywords = ['firebase', 'googleapis', 'genai', 'openai', 'anthropic'];
    
    if (highRiskKeywords.includes(keyword)) return 'critical';
    if (mediumRiskKeywords.includes(keyword)) return 'high';
    return 'medium';
  }
  
  performAdvancedSecurityChecks(filePath, content) {
    const threats = [];
    
    // Check for hardcoded credentials
    const credentialPatterns = [
      /password\s*[:=]\s*['"][^'"]{8,}['"]/gi,
      /api[_-]?key\s*[:=]\s*['"][^'"]{20,}['"]/gi,
      /secret\s*[:=]\s*['"][^'"]{16,}['"]/gi,
      /token\s*[:=]\s*['"][^'"]{20,}['"]/gi
    ];
    
    credentialPatterns.forEach(pattern => {
      if (pattern.test(content)) {
        threats.push({
          id: uuidv4(),
          type: 'Credential Exposure',
          severity: 'critical',
          file: filePath,
          message: 'Potential hardcoded credentials detected',
          timestamp: new Date().toISOString(),
          scanId: this.scanCount
        });
      }
    });
    
    // Check for suspicious network activity
    const networkPatterns = [
      /https?:\/\/[^\/\s'"]+\.onion/gi, // Tor URLs
      /eval\s*\(/gi, // Code injection
      /exec\s*\(/gi, // Command execution
      /shell_exec\s*\(/gi // Shell execution
    ];
    
    networkPatterns.forEach(pattern => {
      if (pattern.test(content)) {
        threats.push({
          id: uuidv4(),
          type: 'Suspicious Code Execution',
          severity: 'high',
          file: filePath,
          message: 'Potentially dangerous code execution pattern detected',
          timestamp: new Date().toISOString(),
          scanId: this.scanCount
        });
      }
    });
    
    return threats;
  }
  
  isDuplicateThreat(newThreat) {
    // Check if similar threat was detected in last 5 scans
    const recentThreats = this.threatHistory.slice(-50);
    return recentThreats.some(threat => 
      threat.file === newThreat.file && 
      threat.keyword === newThreat.keyword &&
      threat.type === newThreat.type
    );
  }
  
  handleThreats(threats) {
    threats.forEach(threat => {
      this.threatHistory.push(threat);
      this.logThreat(threat);
      this.speakThreatAlert(threat);
      this.sendSMSAlert(threat);
    });
    
    // Keep threat history manageable
    if (this.threatHistory.length > 1000) {
      this.threatHistory = this.threatHistory.slice(-500);
    }
  }
  
  logThreat(threat) {
    const severityIcon = {
      'low': 'ℹ️',
      'medium': '⚠️',
      'high': '🔥',
      'critical': '🚨'
    };
    
    console.log(`${severityIcon[threat.severity]} THREAT DETECTED:`);
    console.log(`   Type: ${threat.type}`);
    console.log(`   Severity: ${threat.severity.toUpperCase()}`);
    console.log(`   File: ${threat.file}`);
    console.log(`   Message: ${threat.message}`);
    if (threat.keyword) console.log(`   Keyword: ${threat.keyword}`);
    console.log(`   Time: ${threat.timestamp}`);
    console.log('');
  }
  
  speakAlert(message) {
    // Use macOS 'say' command if available
    if (process.platform === 'darwin') {
      exec(`say "${message}"`, (error) => {
        if (error) console.log('💬 Speech synthesis not available');
      });
    } else {
      console.log(`💬 ALERT: ${message}`);
    }
  }
  
  speakThreatAlert(threat) {
    const message = `Security threat detected: ${threat.type}. Severity level ${threat.severity}. Check file ${path.basename(threat.file)}.`;
    this.speakAlert(message);
  }
  
  sendSMSAlert(threat) {
    // Use Twilio configuration from environment
    const twilioSID = process.env.TWILIO_SID;
    const twilioToken = process.env.TWILIO_TOKEN;
    const twilioFrom = process.env.TWILIO_FROM;
    const twilioTo = process.env.TWILIO_TO;
    
    if (!twilioSID || !twilioToken || !twilioFrom || !twilioTo) {
      console.log('📱 SMS configuration incomplete. Text alerts disabled.');
      return;
    }
    
    const message = `🚨 DevAssist Security Alert: [${threat.severity.toUpperCase()}] ${threat.type} detected in ${path.basename(threat.file)}. ${threat.message}`;
    
    // Use curl to send SMS via Twilio
    const curlCommand = `curl -X POST "https://api.twilio.com/2010-04-01/Accounts/${twilioSID}/Messages.json" \\
      --data-urlencode "From=${twilioFrom}" \\
      --data-urlencode "To=${twilioTo}" \\
      --data-urlencode "Body=${message}" \\
      -u "${twilioSID}:${twilioToken}"`;
    
    exec(curlCommand, (error, stdout, stderr) => {
      if (error) {
        console.log('📱 SMS sending failed:', error.message);
      } else {
        console.log('📱 SMS alert sent successfully');
      }
    });
  }
  
  getStatus() {
    return {
      isMonitoring: this.isMonitoring,
      scanCount: this.scanCount,
      threatCount: this.threatHistory.length,
      lastScan: this.scanCount > 0 ? new Date().toISOString() : null
    };
  }
  
  generateTestThreat() {
    const testThreat = {
      id: uuidv4(),
      type: 'Test Alert',
      severity: 'medium',
      file: 'test-file.js',
      message: 'This is a test security alert to verify system functionality',
      timestamp: new Date().toISOString(),
      scanId: this.scanCount
    };
    
    this.handleThreats([testThreat]);
  }
}

// CLI Interface
if (require.main === module) {
  const monitor = new ContinuousSecurityMonitor();
  
  // Handle command line arguments
  const args = process.argv.slice(2);
  const command = args[0];
  
  switch (command) {
    case 'start':
      const interval = parseInt(args[1]) || 60;
      monitor.startContinuousMonitoring(interval);
      
      // Handle graceful shutdown
      process.on('SIGINT', () => {
        console.log('\\n🛑 Shutting down security monitor...');
        monitor.stopMonitoring();
        process.exit(0);
      });
      
      // Keep the process running
      setInterval(() => {}, 1000);
      break;
      
    case 'stop':
      monitor.stopMonitoring();
      break;
      
    case 'scan':
      monitor.performScan();
      break;
      
    case 'test':
      monitor.generateTestThreat();
      break;
      
    case 'status':
      console.log('🛡️  Security Monitor Status:', monitor.getStatus());
      break;
      
    default:
      console.log('🛡️  DevAssist Continuous Security Monitor');
      console.log('Usage:');
      console.log('  node continuousSecurityMonitor.js start [interval_seconds]  - Start continuous monitoring');
      console.log('  node continuousSecurityMonitor.js scan                      - Perform single scan');
      console.log('  node continuousSecurityMonitor.js test                      - Generate test alert');
      console.log('  node continuousSecurityMonitor.js status                    - Show status');
      console.log('  node continuousSecurityMonitor.js stop                      - Stop monitoring');
      break;
  }
}

module.exports = ContinuousSecurityMonitor;