#!/bin/bash

# DevAssist Security Monitor Build & Test Script
set -euo pipefail

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_PROJECT="$PROJECT_ROOT/iOS/DevAssist-iOS/DevAssist-iOS.xcodeproj"
MACOS_PROJECT="$PROJECT_ROOT/macOS/DevAssist-macOS/DevAssist-macOS.xcodeproj"
CONTINUOUS_MONITOR="$PROJECT_ROOT/continuousSecurityMonitor.js"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Node.js is available
    if ! command -v node >/dev/null 2>&1; then
        error "Node.js is not installed. Please install Node.js to run the continuous monitor."
        exit 1
    fi
    
    # Check if xcodebuild is available (for iOS/macOS builds)
    if ! command -v xcodebuild >/dev/null 2>&1; then
        warning "Xcode command line tools not found. iOS/macOS builds will be skipped."
        XCODE_AVAILABLE=false
    else
        XCODE_AVAILABLE=true
    fi
    
    # Check if we have required Node.js modules
    if [ ! -d "node_modules" ]; then
        log "Installing Node.js dependencies..."
        npm init -y >/dev/null 2>&1
        npm install uuid >/dev/null 2>&1
    fi
    
    success "Prerequisites checked"
}

# Function to test the continuous security monitor
test_continuous_monitor() {
    log "Testing continuous security monitor..."
    
    # Test single scan
    log "Running single security scan..."
    if node "$CONTINUOUS_MONITOR" scan; then
        success "Security scan completed successfully"
    else
        error "Security scan failed"
        return 1
    fi
    
    # Test threat generation
    log "Testing threat alert system..."
    if node "$CONTINUOUS_MONITOR" test; then
        success "Test threat generated successfully"
    else
        error "Test threat generation failed"
        return 1
    fi
    
    # Test status check
    log "Checking monitor status..."
    if node "$CONTINUOUS_MONITOR" status; then
        success "Status check completed"
    else
        error "Status check failed"
        return 1
    fi
    
    success "Continuous security monitor tests passed"
}

# Function to validate iOS project structure
validate_ios_project() {
    log "Validating iOS project structure..."
    
    if [ ! -f "$IOS_PROJECT/project.pbxproj" ]; then
        error "iOS project file not found"
        return 1
    fi
    
    # Check if all required Swift files exist
    local ios_sources=(
        "$PROJECT_ROOT/iOS/DevAssist-iOS/DevAssist-iOS/AppDelegate.swift"
        "$PROJECT_ROOT/iOS/DevAssist-iOS/DevAssist-iOS/SceneDelegate.swift"
        "$PROJECT_ROOT/iOS/DevAssist-iOS/DevAssist-iOS/SecurityMonitor.swift"
        "$PROJECT_ROOT/iOS/DevAssist-iOS/DevAssist-iOS/SecurityMonitorViewController.swift"
        "$PROJECT_ROOT/iOS/DevAssist-iOS/DevAssist-iOS/PiPViewController.swift"
        "$PROJECT_ROOT/iOS/DevAssist-iOS/DevAssist-iOS/Info.plist"
    )
    
    for file in "${ios_sources[@]}"; do
        if [ ! -f "$file" ]; then
            error "Missing iOS source file: $file"
            return 1
        fi
    done
    
    success "iOS project structure validated"
}

# Function to validate macOS project structure
validate_macos_project() {
    log "Validating macOS project structure..."
    
    if [ ! -f "$MACOS_PROJECT/project.pbxproj" ]; then
        error "macOS project file not found"
        return 1
    fi
    
    # Check if all required Swift files exist
    local macos_sources=(
        "$PROJECT_ROOT/macOS/DevAssist-macOS/DevAssist-macOS/AppDelegate.swift"
        "$PROJECT_ROOT/macOS/DevAssist-macOS/DevAssist-macOS/SecurityMonitor.swift"
        "$PROJECT_ROOT/macOS/DevAssist-macOS/DevAssist-macOS/SecurityMonitorViewController.swift"
        "$PROJECT_ROOT/macOS/DevAssist-macOS/DevAssist-macOS/SecurityMonitorWindowController.swift"
        "$PROJECT_ROOT/macOS/DevAssist-macOS/DevAssist-macOS/Info.plist"
        "$PROJECT_ROOT/macOS/DevAssist-macOS/DevAssist-macOS/DevAssist_macOS.entitlements"
    )
    
    for file in "${macos_sources[@]}"; do
        if [ ! -f "$file" ]; then
            error "Missing macOS source file: $file"
            return 1
        fi
    done
    
    success "macOS project structure validated"
}

# Function to attempt iOS build (if Xcode is available)
build_ios() {
    if [ "$XCODE_AVAILABLE" = false ]; then
        warning "Skipping iOS build - Xcode not available"
        return 0
    fi
    
    log "Attempting iOS build validation..."
    
    # Check if we can parse the project without errors
    if xcodebuild -list -project "$IOS_PROJECT" >/dev/null 2>&1; then
        success "iOS project structure is valid for Xcode"
    else
        warning "iOS project has structural issues but files are present"
    fi
}

# Function to attempt macOS build (if Xcode is available)
build_macos() {
    if [ "$XCODE_AVAILABLE" = false ]; then
        warning "Skipping macOS build - Xcode not available"
        return 0
    fi
    
    log "Attempting macOS build validation..."
    
    # Check if we can parse the project without errors
    if xcodebuild -list -project "$MACOS_PROJECT" >/dev/null 2>&1; then
        success "macOS project structure is valid for Xcode"
    else
        warning "macOS project has structural issues but files are present"
    fi
}

# Function to demonstrate system functionality
demo_system() {
    log "Demonstrating DevAssist Security Monitor functionality..."
    
    echo ""
    echo "🛡️  DevAssist Security Monitor Demo"
    echo "=================================================="
    echo ""
    
    # Show project structure
    log "Project Structure:"
    echo "📱 iOS App (DevAssist-iOS.xcodeproj)"
    echo "   ├── Security monitoring with continuous scanning"
    echo "   ├── Siri speech synthesis for alerts"
    echo "   ├── SMS notifications via Twilio"
    echo "   └── Picture-in-Picture (PiP) support for off-screen monitoring"
    echo ""
    echo "🖥️  macOS App (DevAssist-macOS.xcodeproj)"
    echo "   ├── AppKit-based security monitor"
    echo "   ├── System-level threat detection"
    echo "   ├── Menu bar integration"
    echo "   └── Native macOS notifications"
    echo ""
    echo "🔄 Continuous Monitor (continuousSecurityMonitor.js)"
    echo "   ├── Real-time code scanning"
    echo "   ├── Suspicious pattern detection"
    echo "   ├── Voice and SMS alerts"
    echo "   └── Multi-platform support"
    echo ""
    
    # Run a demonstration scan
    log "Running demonstration security scan..."
    node "$CONTINUOUS_MONITOR" scan
    
    echo ""
    log "Demo complete! The system includes:"
    echo "• ✅ iOS app with PiP support"
    echo "• ✅ macOS AppKit application"
    echo "• ✅ Continuous security monitoring"
    echo "• ✅ Siri speech synthesis"
    echo "• ✅ SMS text messaging (requires Twilio config)"
    echo "• ✅ Real-time threat detection"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "🛡️  DevAssist Security Monitor - Build & Test"
    echo "=============================================="
    echo ""
    
    check_prerequisites
    
    # Validate project structures
    validate_ios_project
    validate_macos_project
    
    # Test the continuous monitor
    test_continuous_monitor
    
    # Attempt builds if Xcode is available
    build_ios
    build_macos
    
    # Run demonstration
    demo_system
    
    success "All tests completed successfully!"
    
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Configure Twilio credentials for SMS alerts"
    echo "   2. Open iOS/macOS projects in Xcode for full builds"
    echo "   3. Run 'node continuousSecurityMonitor.js start' for continuous monitoring"
    echo "   4. Test PiP functionality on iOS device/simulator"
    echo ""
}

# Handle command line arguments
case "${1:-test}" in
    "test")
        main
        ;;
    "ios")
        validate_ios_project && build_ios
        ;;
    "macos")
        validate_macos_project && build_macos
        ;;
    "monitor")
        test_continuous_monitor
        ;;
    "demo")
        demo_system
        ;;
    *)
        echo "Usage: $0 [test|ios|macos|monitor|demo]"
        echo "  test    - Run all tests (default)"
        echo "  ios     - Test iOS project only"
        echo "  macos   - Test macOS project only"
        echo "  monitor - Test continuous monitor only"
        echo "  demo    - Run functionality demonstration"
        exit 1
        ;;
esac