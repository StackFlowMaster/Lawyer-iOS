//
//  CallVC.swift
//  Lawyer
//
//  Created by Admin on 2/13/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import AVKit
import Quickblox
import QuickbloxWebRTC

enum CallViewControllerState : Int {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

struct CallStateConstant {
    static let disconnected = "Disconnected"
    static let connecting = "Connecting..."
    static let connected = "Connected"
    static let disconnecting = "Disconnecting..."
}

struct CallConstant {
    static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let unknownUserLabel = "Unknown user"
    static let sharingViewControllerIdentifier = "SharingViewController"
    static let refreshTimeInterval: TimeInterval = 1.0
    
    static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call. Please, reduce the quality of the video settings", comment: "")
    static let sessionDidClose = NSLocalizedString("Session did close due to time out", comment: "")
}


class CallUser {
    //MARK - Properties
    private var user: QBUUser!
    var connectionState: QBRTCConnectionState = .connecting
    var userName: String {
        return user.fullName ?? CallConstant.unknownUserLabel
    }
    
    var userID: UInt {
        return user.id
    }
    
    var bitrate: Double = 0.0
    
    //MARK: - Life Cycle
    required init(user: QBUUser) {
        self.user = user
    }
}

/*
class LocalVideoView: UIView {
    //MARK: - Properties
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    lazy private var containerView: UIView = {
        let containerView = UIView(frame: bounds)
        containerView.backgroundColor = UIColor.clear
        insertSubview(containerView, at: 0)
        return containerView
    }()
    
    //MARK: - Life Circle
    public init(previewlayer layer: AVCaptureVideoPreviewLayer) {
        super.init(frame: CGRect.zero)
        videoLayer = layer
        videoLayer?.videoGravity = .resizeAspect
        containerView.layer.insertSublayer(layer, at:0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = bounds
        videoLayer?.frame = bounds
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateOrientationIfNeeded()
    }
    
    //MARK: - Internal Methods
    private func updateOrientationIfNeeded() {
        let previewLayerConnection = videoLayer?.connection
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        let isVideoOrientationSupported = previewLayerConnection?.isVideoOrientationSupported
        
        guard let videoOrientation = AVCaptureVideoOrientation(rawValue: interfaceOrientation.rawValue),
            isVideoOrientationSupported == true,
            previewLayerConnection?.videoOrientation != videoOrientation else {
                return
        }
        previewLayerConnection?.videoOrientation = videoOrientation
    }
}
*/

class CallVC: UIViewController {
    
    @IBOutlet weak var topWrapper: UIView!
    @IBOutlet weak var topWrapperHeight: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var remoteVideoView: QBRTCRemoteVideoView!
    
    var isPresented: Bool = false
    
    var lawyerzInfo: [String: Any]?
    var remoteUser: QBUUser?
    
    //MARK: - Properties
    private let appManager = AppManager.shared
    
    //MARK: - Internal Properties
    private var timeDuration: TimeInterval = 0.0
    
    private var callTimer: Timer?
    private var beepTimer: Timer?
    
    //Camera
    var session: QBRTCSession?
    var callUUID: UUID?
    private var cameraCapture: QBRTCCameraCapture?
    
    //Containers
    private var users = [CallUser]()
    private var videoViews = [UInt: UIView]()
    private var statsUserID: UInt?
    
    private lazy var statsItem = UIBarButtonItem(title: "Stats",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(updateStatsView))
    
    
    //States
    private var shouldGetStats = false
    private var didStartPlayAndRecord = false
    private var muteVideo = false {
        didSet {
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
        }
    }
    
    private var state = CallViewControllerState.connected {
        didSet {
            switch state {
            case .disconnected:
                title = CallStateConstant.disconnected
            case .connecting:
                title = CallStateConstant.connecting
            case .connected:
                title = CallStateConstant.connected
            case .disconnecting:
                title = CallStateConstant.disconnecting
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        topWrapperHeight.constant = appDelegate.topBarHeight
        
        if (remoteUser == nil) {
            remoteUser = appManager.dataSource.user(withID: session!.initiatorID.uintValue)
        }
        appManager.dataSource.appendSelectedUser(user: remoteUser)
        
        if (lawyerzInfo == nil) {
            getRecipient()
        }
        else {
            refreshUserInfo()
        }
        
        // Reachability
        if Reachability.instance.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
            appManager.dataSource.loadUsers(success: { (response, page, users) in
            }) { (response) in
            }
        }
        
        QBRTCClient.instance().add(self as QBRTCClientDelegate)
        QBRTCAudioSession.instance().addDelegate(self)
        
        let profile = Profile()
        
        guard profile.isFull == true else {
            return
        }
        let currentConferenceUser = CallUser(user: profile.user!)
        
        let audioSession = QBRTCAudioSession.instance()
        if audioSession.isInitialized == false {
            audioSession.initialize { configuration in
                // adding blutetooth support
                configuration.categoryOptions.insert(.allowBluetooth)
                configuration.categoryOptions.insert(.allowBluetoothA2DP)
                configuration.categoryOptions.insert(.duckOthers)
                // adding airplay support
                configuration.categoryOptions.insert(.allowAirPlay)
                guard let session = self.session else { return }
                if session.conferenceType == .video {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                }
            }
        }
        
        configureGUI()
        
        guard let session = self.session else { return }
        if session.conferenceType == .video {
            #if targetEnvironment(simulator)
            // Simulator
            #else
            // Device
            cameraCapture = QBRTCCameraCapture(videoFormat: QBRTCVideoFormat.default(),
                                               position: AVCaptureDevice.Position.front)
            cameraCapture?.startSession(nil)
            session.localMediaStream.videoTrack.videoCapture = cameraCapture
            #endif
        }
        configureVideoViews()
        
        users.insert(currentConferenceUser, at: 0)

        let isInitiator = currentConferenceUser.userID == session.initiatorID.uintValue
        if isInitiator == true {
            startCall()
        } else {
            acceptCall()
        }
        
        title = CallStateConstant.connecting
        timeLabel.text = CallStateConstant.connecting
        
        if session.initiatorID.uintValue == currentConferenceUser.userID {
            CallKitManager.instance.updateCall(with: callUUID, connectingAt: Date())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true {
                self?.cancelCallAlertWith("Error_CheckInternet".localized)
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        
        if cameraCapture?.hasStarted == false {
            cameraCapture?.startSession(nil)
        }
        session?.localMediaStream.videoTrack.videoCapture = cameraCapture
//        reloadContent()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func tapBackButton(_ sender: Any) {
        closeCall()
        if (self.isPresented) {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
        
    @IBAction func tapRearCameraButton(_ sender: Any) {
        guard let cameraCapture = self.cameraCapture else {
            return
        }
        
        let newPosition: AVCaptureDevice.Position = cameraCapture.position == .back ? .front : .back
        guard cameraCapture.hasCamera(for: newPosition) == true else {
            return
        }
        
        let animation = CATransition()
        animation.duration = 0.75
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = CATransitionType(rawValue: "oglFlip")
        animation.subtype = cameraCapture.position == .back ? .fromLeft : .fromRight

        localVideoView.superview?.layer.add(animation, forKey: nil)
        cameraCapture.position = newPosition
    }
    
    @IBAction func tapMuteAudioButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if (self.session?.localMediaStream.audioTrack.isEnabled) != nil {
            self.session?.localMediaStream.audioTrack.isEnabled = !sender.isSelected
        }
    }
    
    @IBAction func tapEndButton(_ sender: Any) {
        closeCall()
        if (self.isPresented) {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func tapChatButton(_ sender: Any) {
        
    }
    
    @IBAction func tapMuteVideoButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        self.muteVideo = sender.isSelected
        self.localVideoView.isHidden = self.muteVideo
    }
    
    func refreshUserInfo() {
        if (lawyerzInfo == nil) {
            return
        }
        
        title = lawyerzInfo![G.full_name] as? String
        
        nameLabel.text = lawyerzInfo![G.full_name] as? String
        guard let profileImageUrl = lawyerzInfo![G.profile_pic] as? String else {
            return
        }
        userImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
    }
     
    //MARK - Setup
    func configureGUI() {
        // when conferenceType is nil, it means that user connected to the session as a listener
        if let conferenceType = session?.conferenceType {
            switch conferenceType {
            case .video:
                self.localVideoView.isHidden = self.muteVideo
                break

            case .audio:
                if UIDevice.current.userInterfaceIdiom == .phone {
                    QBRTCAudioSession.instance().currentAudioDevice = .receiver
//                    dynamicButton.pressed = false

//                    toolbar.add(dynamicButton, action: { sender in
//                        let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
//                        let device = previousDevice == .speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
//                        QBRTCAudioSession.instance().currentAudioDevice = device
//                    })
                }
            @unknown default:
                break
            }

            session?.localMediaStream.audioTrack.isEnabled = true;
//            toolbar.add(audioEnabled, action: { [weak self] sender in
//                guard let self = self else {return}
//
//                if let muteAudio = self.session?.localMediaStream.audioTrack.isEnabled {
//                    self.session?.localMediaStream.audioTrack.isEnabled = !muteAudio
//                }
//            })

            CallKitManager.instance.onMicrophoneMuteAction = { [weak self] in
                guard let self = self else {return}
//                self.audioEnabled.pressed = !self.audioEnabled.pressed
            }

//            toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
//                self?.session?.hangUp(["hangup": "hang up"])
//            })
        }
        
        // add button to enable stats view
        state = .connecting
    }
      
    //MARK - Setup
    func configureVideoViews() {
        if session?.conferenceType == .audio {
            return
        }
        
        if cameraCapture?.hasStarted == false {
            cameraCapture?.startSession(nil)
            session?.localMediaStream.videoTrack.videoCapture = cameraCapture
        }
        
        // Local preview
        if let previewLayer = cameraCapture?.previewLayer {
//            previewLayer.frame = localVideoView.bounds
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            localVideoView.layer.insertSublayer(previewLayer, at:0)
        }
        
        // Remote preview
        let remoteUserID = remoteUser!.id
        if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: remoteUserID)) {

            //Opponents
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            remoteVideoView.setVideoTrack(remoteVideoTraсk)
        }
    }
    
    
    // MARK: - Actions
    
    func startCall() {
        //Begin play calling sound
        beepTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(),
                                         target: self,
                                         selector: #selector(playCallingSound(_:)),
                                         userInfo: nil, repeats: true)
        playCallingSound(nil)
        //Start call
        let userInfo = ["name": "Test", "url": "http.quickblox.com", "param": "\"1,2,3,4\""]
        
        session?.startCall(userInfo)
    }
    
    func acceptCall() {
        SoundProvider.stopSound()
        //Accept call
        let userInfo = ["acceptCall": "userInfo"]
        session?.acceptCall(userInfo)
    }
    
    func closeCall() {
        CallKitManager.instance.endCall(with: callUUID)
        cameraCapture?.stopSession(nil)
        
        let audioSession = QBRTCAudioSession.instance()
        if audioSession.isInitialized == true,
            audioSession.audioSessionIsActivatedOutside(AVAudioSession.sharedInstance()) == false {
            debugPrint("[CallViewController] Deinitializing QBRTCAudioSession.")
            audioSession.deinitialize()
        }
        
        if let beepTimer = beepTimer {
            beepTimer.invalidate()
            self.beepTimer = nil
            SoundProvider.stopSound()
        }
        
        if let callTimer = callTimer {
            callTimer.invalidate()
            self.callTimer = nil
        }
        
        state = .disconnected
        QBRTCClient.instance().remove(self as QBRTCClientDelegate)
        QBRTCAudioSession.instance().removeDelegate(self)
        
        title = "End - \(string(withTimeDuration: timeDuration))"
        timeLabel.text = "End - \(string(withTimeDuration: timeDuration))"
    }
    
    @objc func updateStatsView() {
        shouldGetStats = !shouldGetStats
//        statsView.isHidden = !statsView.isHidden
    }
    
    @objc func updateStatsState() {
        updateStatsView()
    }
    
    
    //MARK: - Internal Methods
    
    private func zoomUser(userID: UInt) {
        statsUserID = userID
//        reloadContent()
        navigationItem.rightBarButtonItem = statsItem
    }
    
    private func unzoomUser() {
        statsUserID = nil
//        reloadContent()
        navigationItem.rightBarButtonItem = nil
    }
    
    private func createConferenceUser(userID: UInt) -> CallUser {
        guard let user = self.appManager.dataSource.user(withID: userID) else {
            let user = QBUUser()
            user.id = userID
            return CallUser(user: user)
        }
        return CallUser(user: user)
    }
    
    
    // MARK: - Helpers
    
    private func cancelCallAlertWith(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.closeCall()
        }
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    
    // MARK: - Timers actions
    
    @objc func playCallingSound(_ sender: Any?) {
        SoundProvider.playSound(type: .calling)
    }
    
    @objc func refreshCallTime(_ sender: Timer?) {
        timeDuration += CallConstant.refreshTimeInterval
        title = "Call time - \(string(withTimeDuration: timeDuration))"
        timeLabel.text = "\(string(withTimeDuration: timeDuration))"
    }
    
    func string(withTimeDuration timeDuration: TimeInterval) -> String {
        let hours = Int(timeDuration / 3600)
        let minutes = Int(timeDuration / 60)
        let seconds = Int(timeDuration) % 60
        
        var timeStr = ""
        if hours > 0 {
            let minutes = Int((timeDuration - Double(3600 * hours)) / 60);
            timeStr = "\(hours):\(minutes):\(seconds)"
        } else {
            if (seconds < 10) {
                timeStr = "\(minutes):0\(seconds)"
            } else {
                timeStr = "\(minutes):\(seconds)"
            }
        }
        return timeStr
    }
    
    // MARK: - API functins
    
    func getRecipient() {
        if (remoteUser == nil) {
            return
        }
        
        let accountType = AppShared.getAccountType()
        if (accountType == .Lawyer) {
            let userId = remoteUser!.login!.deletingPrefix(G.prefix_user_)
            
//            SVProgressHUD.show()
            AppWebClient.GetAllDetailsUser(userId: userId) { (json) in
//                SVProgressHUD.dismiss()
                
                guard let response = json else {
                    self.showAlert(msg: "Failed to call GetAllDetailsUser api on ChatVC.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
//                    SVProgressHUD.dismiss()
                    self.showAlert(msg: response[G.error].string)
                    return;
                }
                
                let valueArray = response[G.response].arrayObject
                if (valueArray != nil && valueArray!.count > 0) {
                    self.lawyerzInfo = valueArray![0] as? [String: Any]
                    self.refreshUserInfo()
                }
            }
        }
        else if (accountType == .User) {
            let lawyerId = remoteUser!.login
            
//            SVProgressHUD.show()
            AppWebClient.GetAllDetailsLawyer(lawyerId: lawyerId!) { (json) in
//                SVProgressHUD.dismiss()
                
                guard let response = json else {
                    self.showAlert(msg: "Failed to call GetAllDetailsLawyer api on ChatVC.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    self.showAlert(msg: response[G.error].string)
                    return;
                }
                
                let valueArray = response[G.response].arrayObject
                if (valueArray != nil && valueArray!.count > 0) {
                    self.lawyerzInfo = valueArray![0] as? [String: Any]
                    self.refreshUserInfo()
                }
            }
        }
        
    }
}


//extension CallVC: LocalVideoViewDelegate {
//    // MARK: LocalVideoViewDelegate
//    func localVideoView(_ localVideoView: LocalVideoView, pressedSwitchButton sender: UIButton?) {
//        guard let cameraCapture = self.cameraCapture else {
//            return
//        }
//        let newPosition: AVCaptureDevice.Position = cameraCapture.position == .back ? .front : .back
//        guard cameraCapture.hasCamera(for: newPosition) == true else {
//            return
//        }
//        let animation = CATransition()
//        animation.duration = 0.75
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        animation.type = CATransitionType(rawValue: "oglFlip")
//        animation.subtype = cameraCapture.position == .back ? .fromLeft : .fromRight
//
//        localVideoView.superview?.layer.add(animation, forKey: nil)
//        cameraCapture.position = newPosition
//    }
//}

extension CallVC: QBRTCAudioSessionDelegate {
    //MARK: QBRTCAudioSessionDelegate
    func audioSession(_ audioSession: QBRTCAudioSession, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        let isSpeaker = updatedAudioDevice == .speaker
//        dynamicButton.pressed = isSpeaker
    }
}

// MARK: QBRTCClientDelegate

extension CallVC: QBRTCClientDelegate {
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        guard session == self.session else {
            return
        }
        if session.opponentsIDs.count == 1, session.initiatorID == userID {
            closeCall()
        }
    }
    
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        guard let session = session as? QBRTCSession,
            session == self.session,
            let user = users.filter({ $0.userID == userID.uintValue }).first else {
                return
        }
        
        if user.connectionState == .connected,
            report.videoReceivedBitrateTracker.bitrate > 0.0 {
            user.bitrate = report.videoReceivedBitrateTracker.bitrate
            
//            let userIndexPath = self.userIndexPath(userID: user.userID)
//            if let cell = self.opponentsCollectionView.cellForItem(at: userIndexPath) as? UserCell {
//                cell.bitrate = user.bitrate
//            }
        }

        guard let selectedUserID = statsUserID,
            selectedUserID == userID.uintValue,
            shouldGetStats == true else {
                return
        }
        let result = report.statsString()
//        statsView.updateStats(result)
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        if session != self.session {
            return
        }
        // remove user from the collection
        if statsUserID == userID.uintValue {
            unzoomUser()
        }
        
        guard let index = users.firstIndex(where: { $0.userID == userID.uintValue }) else {
            return
        }
        let user = users[index]
        if user.connectionState == .connected {
            return
        }
        
        user.bitrate = 0.0
        
        if let videoView = videoViews[userID.uintValue] as? QBRTCRemoteVideoView {
            videoView.removeFromSuperview()
            videoViews.removeValue(forKey: userID.uintValue)
            let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            videoViews[userID.uintValue] = remoteVideoView
        }
//        reloadContent()
    }
    
    /**
     *  Called in case when connection state changed
     */
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        if session != self.session {
            return
        }
        
        if let index = users.firstIndex(where: { $0.userID == userID.uintValue }) {
            let user = users[index]
            user.connectionState = state
//            let userIndexPath = self.userIndexPath(userID:userID.uintValue)
//            if let cell = self.opponentsCollectionView.cellForItem(at: userIndexPath) as? UserCell {
//                cell.connectionState = user.connectionState
//            }
        }
        else {
            let user = createConferenceUser(userID: userID.uintValue)
            user.connectionState = state
            
            if user.connectionState == .connected {
                self.users.insert(user, at: 0)
//                reloadContent()
            }
        }
    }
    
    /**
     *  Called in case when receive remote video track from opponent
     */
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        if session != self.session {
            return
        }
//        reloadContent()
    }
    
    /**
     *  Called in case when connection is established with opponent
     */
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        if session != self.session {
            return
        }

        if let beepTimer = beepTimer {
            beepTimer.invalidate()
            self.beepTimer = nil
            SoundProvider.stopSound()
        }
        
        if callTimer == nil {
            let profile = Profile()
            if profile.isFull == true,
                self.session?.initiatorID.uintValue == profile.ID {
                CallKitManager.instance.updateCall(with: callUUID, connectedAt: Date())
            }
            
            callTimer = Timer.scheduledTimer(timeInterval: CallConstant.refreshTimeInterval,
                                             target: self,
                                             selector: #selector(refreshCallTime(_:)),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            closeCall()
        }
    }
}
