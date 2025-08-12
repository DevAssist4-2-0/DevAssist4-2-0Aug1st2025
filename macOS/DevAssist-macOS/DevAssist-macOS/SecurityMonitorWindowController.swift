import Cocoa

class SecurityMonitorWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Configure window appearance
        window?.title = "🛡️ DevAssist Security Monitor"
        window?.setContentSize(NSSize(width: 800, height: 600))
        window?.center()
        window?.isRestorable = true
        window?.identifier = NSUserInterfaceItemIdentifier("SecurityMonitorWindow")
        
        // Set minimum window size
        window?.minSize = NSSize(width: 600, height: 400)
        
        // Configure window level for security applications
        window?.level = .floating
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        print("🪟 Security Monitor window loaded")
    }
    
    override func windowWillClose(_ notification: Notification) {
        // Keep monitoring even when window closes
        print("🪟 Security Monitor window closing (monitoring continues)")
    }
}