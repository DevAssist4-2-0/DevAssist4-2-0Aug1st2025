import UIKit
import AVKit
import AVFoundation

class PiPViewController: UIViewController, AVPictureInPictureControllerDelegate {
    static let shared = PiPViewController()
    
    private var playerViewController: AVPlayerViewController?
    private var pipController: AVPictureInPictureController?
    private var player: AVPlayer?
    private var statusLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPictureInPicture()
        setupStatusView()
    }
    
    private func setupPictureInPicture() {
        // Create a dummy video player for PiP functionality
        // In a real implementation, this might show security camera feeds or status indicators
        guard let videoURL = createDummyVideo() else { return }
        
        player = AVPlayer(url: videoURL)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.view.backgroundColor = UIColor.black
        
        // Set up Picture in Picture
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipController = AVPictureInPictureController(playerLayer: playerViewController?.view.layer as! AVPlayerLayer)
            pipController?.delegate = self
        }
    }
    
    private func setupStatusView() {
        // Create a custom view to show security status in PiP
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.95)
        containerView.layer.cornerRadius = 12
        
        // Security status indicator
        let statusIndicator = UIView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        statusIndicator.backgroundColor = SecurityMonitor.shared.isActive ? UIColor.green : UIColor.red
        statusIndicator.layer.cornerRadius = 10
        containerView.addSubview(statusIndicator)
        
        // Status label
        statusLabel = UILabel(frame: CGRect(x: 50, y: 15, width: 250, height: 30))
        statusLabel?.text = SecurityMonitor.shared.isActive ? "Security Monitor Active" : "Security Monitor Inactive"
        statusLabel?.textColor = UIColor.white
        statusLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        containerView.addSubview(statusLabel!)
        
        // Threat count label
        let threatLabel = UILabel(frame: CGRect(x: 20, y: 50, width: 280, height: 25))
        threatLabel.text = "Threats Detected: \(SecurityMonitor.shared.threats.count)"
        threatLabel.textColor = UIColor.white
        threatLabel.font = UIFont.systemFont(ofSize: 12)
        containerView.addSubview(threatLabel)
        
        // Last scan time
        let timeLabel = UILabel(frame: CGRect(x: 20, y: 75, width: 280, height: 25))
        timeLabel.text = "Last Scan: \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))"
        timeLabel.textColor = UIColor.lightGray
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        containerView.addSubview(timeLabel)
        
        // DevAssist branding
        let brandLabel = UILabel(frame: CGRect(x: 20, y: 140, width: 280, height: 25))
        brandLabel.text = "🛡️ DevAssist Security Monitor"
        brandLabel.textColor = UIColor.white
        brandLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        brandLabel.textAlignment = .center
        containerView.addSubview(brandLabel)
        
        view.addSubview(containerView)
    }
    
    private func createDummyVideo() -> URL? {
        // Create a simple video asset for PiP
        // In production, this might be a security camera feed or status visualization
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let videoPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("security_monitor.mp4")
        
        // Create a simple black video if it doesn't exist
        if !FileManager.default.fileExists(atPath: videoPath.path) {
            createSimpleVideo(at: videoPath)
        }
        
        return videoPath
    }
    
    private func createSimpleVideo(at url: URL) {
        // Create a minimal video asset for PiP functionality
        // This is a placeholder - in production you'd use actual security footage
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // Create a simple colored layer
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: 320, height: 180)
        
        // This is a simplified implementation
        // In practice, you'd use AVAssetWriter to create the video file
        print("📹 Security monitor video created at: \(url.path)")
    }
    
    func startPictureInPicture() {
        guard let pipController = pipController else {
            print("⚠️ Picture in Picture not available")
            return
        }
        
        if pipController.isPictureInPictureActive {
            return // Already active
        }
        
        // Start PiP mode
        pipController.startPictureInPicture()
        print("📱 Picture in Picture mode started")
    }
    
    func stopPictureInPicture() {
        guard let pipController = pipController else { return }
        
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
            print("📱 Picture in Picture mode stopped")
        }
    }
    
    // MARK: - AVPictureInPictureControllerDelegate
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("📱 PiP will start")
        updatePiPStatus()
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("📱 PiP did start")
        // Update the PiP content with current security status
        updatePiPContent()
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("📱 PiP will stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("📱 PiP did stop")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("❌ PiP failed to start: \(error.localizedDescription)")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore the full app interface when PiP is tapped
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.makeKeyAndVisible()
        }
        completionHandler(true)
    }
    
    private func updatePiPStatus() {
        DispatchQueue.main.async {
            self.statusLabel?.text = SecurityMonitor.shared.isActive ? "🟢 Monitor Active" : "🔴 Monitor Inactive"
        }
    }
    
    private func updatePiPContent() {
        // Update PiP content with latest security information
        // This would run periodically while in PiP mode
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let pipController = self?.pipController,
                  pipController.isPictureInPictureActive else {
                timer.invalidate()
                return
            }
            
            self?.updatePiPStatus()
        }
    }
}