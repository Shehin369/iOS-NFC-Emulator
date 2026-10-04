//
//// TapToShareUIKit
//// Core ViewController + MultipeerConnectivity + Motion detection
//
//import UIKit
//import MultipeerConnectivity
//import CoreMotion
//
//class ViewControllernew: UIViewController, UITextFieldDelegate {
//
//    let bumpDetector = BumpDetector()
//    let shareManager = TapToShareManager()
//
//    let userIDToSend = "user_123456"
//
//    @IBOutlet weak var inputText: UITextField!
//    @IBOutlet weak var statusLabel: UILabel!
//    @IBOutlet weak var shareButton: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        bumpDetector.onBumpDetected = {
//            self.statusLabel.text = "Bump detected! Connecting..."
//            self.shareManager.send(string: self.userIDToSend)
//        }
//
//        shareManager.onStringReceived = { received in
//            self.statusLabel.text = "Received ID: \(received)"
//            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        }
//    }
//
//    @IBAction func shareButtonTapped(_ sender: Any) {
//        guard let message = inputText.text, !message.isEmpty else {
//            showAlert("Please enter a message to write.")
//            return
//        }
//        self.statusLabel.text = "Looking for nearby device..."
//        bumpDetector.startDetecting()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        bumpDetector.stopDetecting()
//    }
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//    }
//    func showAlert(_ message: String) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "Alert!", message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(alert, animated: true)
//        }
//    }
//}
//
//class BumpDetector {
//    let motionManager = CMMotionManager()
//    var onBumpDetected: (() -> Void)?
//    var lastTriggerTime: Date?
//    func startDetecting() {
//        motionManager.accelerometerUpdateInterval = 0.15
//        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
//            guard let accel = data?.acceleration else { return }
//            let magnitude = sqrt(accel.x * accel.x + accel.y * accel.y + accel.z * accel.z)
//            if magnitude > 1.5 {
//                let now = Date()
//                    if magnitude > 1.2 {
//                        if let last = self.lastTriggerTime, now.timeIntervalSince(last) < 0.5 {
//                            // Ignore repeated triggers in short time (like shake)
//                            return
//                        }
//                self.onBumpDetected?()
//                self.stopDetecting()
//            }
//        }
//    }
//
//    func stopDetecting() {
//        motionManager.stopAccelerometerUpdates()
//    }
//}
//
//class TapToShareManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
//
//    private let serviceType = "tap2share"
//    private let peerID = MCPeerID(displayName: UIDevice.current.name)
//    private var session: MCSession!
//    private var advertiser: MCNearbyServiceAdvertiser!
//    private var browser: MCNearbyServiceBrowser!
//
//    var onStringReceived: ((String) -> Void)?
//
//    override init() {
//        super.init()
//        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
//        session.delegate = self
//
//        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
//        advertiser.delegate = self
//        advertiser.startAdvertisingPeer()
//
//        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
//        browser.delegate = self
//        browser.startBrowsingForPeers()
//    }
//
//    func send(string: String) {
//        if !session.connectedPeers.isEmpty, let data = string.data(using: .utf8) {
//            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
//        }
//    }
//
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        if let str = String(data: data, encoding: .utf8) {
//            DispatchQueue.main.async {
//                self.onStringReceived?(str)
//            }
//        }
//    }
//    func session(_: MCSession, didReceive: InputStream, withName: String, fromPeer: MCPeerID) {}
//    func session(_: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) {}
//    func session(_: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) {}
//
//    func advertiser(_: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
//                    withContext: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        invitationHandler(true, session)
//    }
//
//    func browser(_: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo: [String : String]?) {
//        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
//    }
//    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
//}
