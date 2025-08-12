import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Start security monitoring on app launch
        SecurityMonitor.shared.startContinuousMonitoring()
        
        // Setup menu bar icon for quick access
        setupMenuBarIcon()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Stop monitoring when app terminates
        SecurityMonitor.shared.stopMonitoring()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show main window when dock icon is clicked
        if !flag {
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
        return true
    }
    
    private func setupMenuBarIcon() {
        // This would create a menu bar icon for quick access to security status
        // Implementation would depend on specific requirements
        print("🍎 DevAssist Security Monitor for macOS launched")
    }
}