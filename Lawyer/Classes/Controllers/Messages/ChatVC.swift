//
//  ChatVC.swift
//  Lawyer
//
//  Created by Admin on 11/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import AVKit
import Photos
import SafariServices
import CoreTelephony
import TTTAttributedLabel


var messageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }
    return Static.instance
}


class ChatVC: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var headerWrapper: UIView!
    @IBOutlet weak var headerWrapperHeight: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headerButton: UIButton!
    
//    @IBOutlet weak var chatsTableView: UITableView!
    @IBOutlet weak var collectionView: ChatCollectionView!
    
    @IBOutlet weak var composeWrapper: UIView!
    @IBOutlet weak var composeShadowView: UIView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var actionWrapper: UIView!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var actionButtonAudio: UIButton!
    @IBOutlet weak var actionButtonVideo: UIButton!
    @IBOutlet weak var actionButtonHire: UIButton!
    @IBOutlet weak var actionWrapperBottom: NSLayoutConstraint!
    
    @IBOutlet private weak var collectionBottomConstraint: NSLayoutConstraint!
    
    
    private var userInfo: [String: Any]?

    
    let attachmentBarHeight: CGFloat = 100.0
    
    
    //MARK: - Properties
    private lazy var dataSource: ChatDataSource = {
        let dataSource = ChatDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    private let chatManager = ChatManager.instance
    
    private let outgoingBubble = UIImage(named: "bg_outgoingcell")
    private let incomingBubble = UIImage(named: "bg_incomingcell")
    
    private var isDeviceLocked = false
    
    private var isUploading = false
    private var attachmentMessage: QBChatMessage?
    
    /**
     *  This property is required when creating a ChatViewController.
     */
    var dialogID: String! {
        didSet {
            self.dialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    private var dialog: QBChatDialog!
    
    private var currentUser = Profile()
    private var recipient: QBUUser?
    
    private var currentUserAvatar: UIImage?
    private var recipientAvatar: UIImage?
    var recipientAvatarUrl: String?
    
    private var actionsHandler: ChatActionsHandler?
    internal var senderDisplayName = ""
    internal var senderID: UInt = 0
    
    private var automaticallyScrollsToMostRecentMessage = true
    
    private var topContentAdditionalInset: CGFloat = 0.0 {
        didSet {
            updateCollectionViewInsets()
        }
    }
    
    private var enableTextCheckingTypes: NSTextCheckingTypes = NSTextCheckingAllTypes
    
    private var collectionBottomConstant: CGFloat = 0.0
    
    //MARK: - Private Properties
    private var isMenuVisible: Bool {
        return selectedIndexPathForMenu != nil && UIMenuController.shared.isMenuVisible
    }
    
    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
//        pickerController.modalPresentationStyle = .fullScreen
        return pickerController
    }()
    
    private var cancel = false
    
    private var willResignActiveBlock: AnyObject?
    private var willActiveBlock: AnyObject?
    
    private var selectedIndexPathForMenu: IndexPath?
    
    private lazy var attachmentBar: AttachmentBar = {
        let attachmentBar = AttachmentBar()
        attachmentBar.setRoundBorderEdgeView(cornerRadius: 0.0, borderWidth: 0.5, borderColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        return attachmentBar
    }()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        QBChat.instance.addDelegate(self)
        setupViewMessages()
        dataSource.delegate = self
        setupBarButtonsEnabled(left: true, right: false)
        
//        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = [] //same UIRectEdgeNone
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadChat()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let willResignActive = willResignActiveBlock {
            NotificationCenter.default.removeObserver(willResignActive)
        }
        if let willActiveBlock = willActiveBlock {
            NotificationCenter.default.removeObserver(willActiveBlock)
        }
        NotificationCenter.default.removeObserver(self)
        // clearing typing status blocks
        dialog.clearTypingStatusBlocks()
        registerForNotifications(false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - UI functions
    
    func initUI() {
        self.tabBarController?.tabBar.isHidden = true
        
        headerWrapperHeight.constant = appDelegate.topBarHeight
        
        self.userImageView.layer.borderWidth = 0.5
        self.userImageView.layer.borderColor = UIColor.white.cgColor
        self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
        
//        self.userImageView.image = UIImage(named: self.conversation!.lawyer!.imageUrl!)
//        self.nameLabel.text = self.conversation?.lawyer?.full_name
        
        userImageView.image = nil
        if (recipientAvatarUrl != nil) {
//            userImageView.sd_setImage(with: URL(string: recipientAvatarUrl!), completed: nil)
            userImageView.sd_setImage(with: URL(string: recipientAvatarUrl!)) { (downloadedImage, error, cacheType, url) in
                if self.recipientAvatar == nil {
                    self.userImageView.image = downloadedImage
                }
            }
        }
        
        self.actionWrapper.shadow()
        self.composeShadowView.shadow()
    }
    
    func updateWrapper() {
        headerWrapperHeight.constant = appDelegate.topBarHeight
        view.layoutIfNeeded()
    }
    
    func reloadAvatars() {
        if let blobID = recipient?.blobID {
            self.recipientAvatar = nil
            AppManager.shared.downloadQBUserAvatar(blobID) { (avatar) in
                if let avatar = avatar {
                    self.recipientAvatar = avatar
                }
                self.collectionView.reloadData()
            }
        }
        
        if let blobID = currentUser.user?.blobID {
            self.currentUserAvatar = nil
            AppManager.shared.downloadQBUserAvatar(blobID) { (avatar) in
                if let avatar = avatar {
                    self.currentUserAvatar = avatar
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    func reloadChat() {
        
        let chat = QBChat.instance
        chat.addDelegate(self)
        
        currentUser = Profile()
        recipient = ChatManager.instance.storage.user(withID: UInt(dialog.recipientID))
        
        guard currentUser.isFull == true else {
            return
        }

        if chat.isConnected == true {
            loadMessages()
        }
        
        senderID = currentUser.ID
        nameLabel.text = dialog!.name ?? ""
        
        reloadAvatars()
        
        registerForNotifications(true)
        
        willResignActiveBlock = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.isDeviceLocked = true
        }
        willActiveBlock = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.isDeviceLocked = false
//            self?.chatsTableView.reloadData()
            self?.collectionView.reloadData()
        }
        
//        if messageField.isFirstResponder == false {
//            toolbarBottomLayoutGuide.constant = CGFloat(inputToolBarStartPos)
//        }
        updateCollectionViewInsets()
        collectionBottomConstraint.constant = collectionBottomConstant
//        if dialog.type != .publicGroup {
//            navigationItem.rightBarButtonItem = infoItem
//        }
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true, self?.isUploading == true {
                self?.cancelUploadFile()
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        updateConnectionStatus?(Reachability.instance.networkConnectionStatus())
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func tapHeaderButton(_ sender: Any) {
        
        dismiss(animated: false) {
        }
        
        let mainTabVC = AppManager.shared.mainTabVC
        mainTabVC.tapTabButton(mainTabVC.tabButtonProfile)
    }
    
    @IBAction func tapMenuButton(_ sender: Any) {
        
    }
    
    @IBAction func tapCameraButton(_ sender: UIButton) {
        // hide keyboard
        view.window?.endEditing(true)
        
//        self.showAlert()
        
        didPressAccessoryButton(sender)
    }
    
    @IBAction func tapSendButton(_ sender: UIButton) {
        // hide keyboard
        view.window?.endEditing(true)
        
//        guard let msg = self.messageField.text, msg.count > 0 else {
//            return
//        }
//
//        self.messageField.text = nil
        
        didPressSend(sender)
    }
    
    @IBAction func tapArrowButton(_ sender: UIButton) {
        showActionWrapper(show: !sender.isSelected)
    }
    
    @IBAction func tapActionButton(_ sender: UIButton) {
        let recipientID = dialog.recipientID
        guard let qbUser = chatManager.storage.user(withID: UInt(recipientID)) else {
            return
        }
        
        showActionWrapper(show: false)
        
        let appManager = AppManager.shared
        
        if (sender == actionButtonAudio) {
            appManager.dataSource.appendSelectedUser(user: qbUser)
            appManager.call(with: .audio, qbUser: qbUser, lawyerzInfo: userInfo)
        }
        else if (sender == actionButtonVideo) {
            appManager.dataSource.appendSelectedUser(user: qbUser)
            appManager.call(with: .video, qbUser: qbUser, lawyerzInfo: userInfo)
        }
        else if (sender == actionButtonHire) {
        }
    }
    
    func showActionWrapper(show: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.actionWrapperBottom.constant = show ? self.composeWrapper.frame.height + 10.0 : 0.0
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.arrowButton.isSelected = show
            let imageName = show ? "ic_down" : "ic_up"
            self.arrowButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    //Show alert
    func showAlert() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //get image from source type
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func sendPhoto(image: UIImage) {
//        let message = Message(messageId: 20, message: "", image: image, time: "", isIncoming: false, lawyer: self.conversation!.lawyer!)
//        self.conversation?.messages.append(message)
//
//        self.chatsTableView.reloadData()
//        self.chatsTableView.scrollToRow(at: IndexPath(row: self.conversation!.messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    
    //MARK: - Internal Methods
    //MARK: - Setup
    private func setupViewMessages() {
        registerCells()
        collectionView.transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: 0.0)
//        setupInputToolbar()
    }
    
    private func registerCells() {
        if let headerNib = HeaderCollectionReusableView.nib(),
            let headerIdentifier = HeaderCollectionReusableView.cellReuseIdentifier() {
            collectionView.register(headerNib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                    withReuseIdentifier: headerIdentifier)
        }
        ChatEmptyCell.registerForReuse(inView: collectionView!)
        ChatNotificationCell.registerForReuse(inView: collectionView!)
        ChatOutgoingCell.registerForReuse(inView: collectionView!)
        ChatIncomingCell.registerForReuse(inView: collectionView!)
        ChatAttachmentIncomingCell.registerForReuse(inView: collectionView!)
        ChatAttachmentOutgoingCell.registerForReuse(inView: collectionView!)
    }
    
    
    // MARK: - Actions
    

    func getRecipient() {
        let recipientID = dialog.recipientID
        guard let recipient = chatManager.storage.user(withID: UInt(recipientID)) else {
            return
        }
        
        let qbLoginOfRecipient = recipient.login
        if qbLoginOfRecipient!.hasPrefix(G.prefix_user_) {
            let userId = recipient.login!.deletingPrefix(G.prefix_user_)
            
            SVProgressHUD.show()
            AppWebClient.GetAllDetailsUser(userId: userId) { (json) in
                SVProgressHUD.dismiss()
                
                guard let response = json else {
                    self.showAlert(msg: "Failed to call GetAllDetailsUser api on ChatVC.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: response[G.error].string)
                    return;
                }
                
                let valueArray = response[G.response].arrayObject
                if (valueArray != nil && valueArray!.count > 0) {
                    self.userInfo = valueArray![0] as? [String: Any]
                    self.refreshUserInfo()
                }
            }
        }
        else {
            let lawyerId = recipient.login
            
            SVProgressHUD.show()
            AppWebClient.GetAllDetailsLawyer(lawyerId: lawyerId!) { (json) in
                SVProgressHUD.dismiss()
                
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
                    self.userInfo = valueArray![0] as? [String: Any]
                    self.refreshUserInfo()
                }
            }
        }
        
    }
    
    func refreshUserInfo() {
        if (userInfo == nil) {
            return
        }
        
        nameLabel.text = userInfo![G.full_name] as? String
    }
    
    private func cancelUploadFile() {
        hideAttacnmentBar()
        isUploading = false
        let alertController = UIAlertController(title: "ERROR".localized,
                                                message: "FAILED_UPLOAD_ATTACHMENT".localized,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel) { (action) in
            self.setupBarButtonsEnabled(left: true, right: false)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func viewClass(forItem item: QBChatMessage) -> ChatReusableViewProtocol.Type {
        
        if item.customParameters["notification_type"] != nil || item.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            return ChatNotificationCell.self
        }
        let hasAttachment = item.attachments?.isEmpty == false
        if item.senderID != senderID {
            return hasAttachment ? ChatAttachmentIncomingCell.self : ChatIncomingCell.self
        } else {
            return hasAttachment ? ChatAttachmentOutgoingCell.self : ChatOutgoingCell.self
        }
    }
    
    private func attributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        guard let text = messageItem.text  else {
            return nil
        }
        var textString = text
        var textColor = messageItem.senderID == senderID ? UIColor.white : .black
        if messageItem.customParameters["notification_type"] != nil || messageItem.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            textColor = G.greenTextColor
        }
        if messageItem.customParameters["notification_type"] != nil {
            if let dateSent = messageItem.dateSent {
                textString = messageTimeDateFormatter.string(from: dateSent) + "\n" + textString
            }
        }
        let font = UIFont(name: "Helvetica", size: 17)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any]
        return NSAttributedString(string: textString, attributes: attributes)
    }
    
    private func topLabelAttrString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        if dialog.type == .private,
            messageItem.senderID == senderID {
                return nil
        }
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byTruncatingTail
        let color = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let font = UIFont(name: "Helvetica", size: 17)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        let topLabelString = chatManager.storage.user(withID: messageItem.senderID)?.fullName ?? "@\(messageItem.senderID)"
        return NSAttributedString(string: topLabelString, attributes: attributes)
    }
    
    private func bottomLabelAttrString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        let textColor = messageItem.senderID == senderID ? UIColor.white : .black
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byWordWrapping
        let font = UIFont(name: "Helvetica", size: 13)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        guard let dateSent = messageItem.dateSent else {
            return NSAttributedString(string: "")
        }
        var text = messageTimeDateFormatter.string(from: dateSent)
        if messageItem.senderID == self.senderID {
            text = text + "\n" + statusStringFromMessage(message: messageItem)
        }
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    private func statusStringFromMessage(message: QBChatMessage) -> String {
        var statusString = ""
        var readLogins: [String] = []
        //check and add users who read the message
        if let readIDs = message.readIDs?.filter({ $0 != NSNumber(value: senderID) }),
            readIDs.isEmpty == false {
            for readID in readIDs {
                guard let user = chatManager.storage.user(withID: readID.uintValue) else {
                    let userLogin = "@\(readID)"
                    readLogins.append(userLogin)
                    continue
                }
                let userName = user.fullName ?? user.login ?? ""
                if readLogins.contains(userName) {
                    continue
                }
                readLogins.append(userName)
            }
            statusString += message.attachments?.isEmpty == false ? "SEEN_STATUS".localized : "READ_STATUS".localized;
            statusString += ": " + readLogins.joined(separator: ", ")
        }
        //check and add users to whom the message was delivered
        if let deliveredIDs = message.deliveredIDs?.filter({ $0 != NSNumber(value: senderID) }) {
            var deliveredLogins: [String] = []
            for deliveredID in deliveredIDs {
                guard let user = chatManager.storage.user(withID: deliveredID.uintValue) else {
                    let userLogin = "@\(deliveredID)"
                    if readLogins.contains(userLogin) == false {
                        deliveredLogins.append(userLogin)
                    }
                    continue
                }
                let userName = user.fullName ?? user.login ?? ""
                if readLogins.contains(userName) {
                    continue
                }
                if deliveredLogins.contains(userName) {
                    continue
                }
                
                deliveredLogins.append(userName)
            }
            if deliveredLogins.isEmpty == false {
                if statusString.isEmpty == false {
                    statusString += "\n"
                }
                statusString += "DELIVERED_STATUS".localized + ": " + deliveredLogins.joined(separator: ", ")
            }
        }
        return statusString.isEmpty ? "SENT_STATUS".localized : statusString
    }
    
    private func finishSendingMessage() {
        finishSendingMessage(animated: true)
    }
    
    private func setupBarButtonsEnabled(left: Bool, right: Bool) {
        cameraButton.isEnabled = left
        sendButton.isEnabled = right
    }
    
    private func finishSendingMessage(animated: Bool) {
        messageField.text = nil
        messageField.attributedText = nil
        messageField.undoManager?.removeAllActions()
        
        if attachmentMessage != nil {
            attachmentMessage = nil
        }
        
        if isUploading == true {
            setupBarButtonsEnabled(left: false, right: false)
        }
        else {
            setupBarButtonsEnabled(left: true, right: false)
        }
        
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: messageField)
        
        if automaticallyScrollsToMostRecentMessage {
            scrollToBottomAnimated(animated)
        }
    }
    
    private func scrollToBottomAnimated(_ animated: Bool) {
        if collectionView.numberOfItems(inSection: 0) == 0 {
            return
        }
        
        var contentOffset = collectionView.contentOffset
        
        if contentOffset.y == 0 {
            return
        }
        contentOffset.y = 0
        collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    private func hideKeyboard(animated: Bool) {
        let hideKeyboardBlock = { [weak self] in
            if self?.messageField.isFirstResponder == true {
                self?.messageField.resignFirstResponder()
            }
        }
        if animated {
            hideKeyboardBlock()
        } else {
            UIView.performWithoutAnimation(hideKeyboardBlock)
        }
    }
    
    private func loadMessages(with skip: Int = 0) {
        SVProgressHUD.show()
        chatManager.messages(withID: dialogID, skip: skip, successCompletion: { [weak self] (messages, cancel) in
            self?.cancel = cancel
            self?.dataSource.addMessages(messages)
            SVProgressHUD.dismiss()
        }, errorHandler: { [weak self] (error) in
            if error == ChatManagerConstant.notFound {
                self?.dataSource.clear()
                self?.dialog.clearTypingStatusBlocks()
                self?.composeWrapper.isUserInteractionEnabled = false
                self?.collectionView.isScrollEnabled = false
                self?.collectionView.reloadData()
                self?.title = ""
                self?.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            SVProgressHUD.showError(withStatus: error)
        })
    }
    
    private func updateCollectionViewInsets() {
        if topContentAdditionalInset > 0.0 {
            var contentInset = collectionView.contentInset
            contentInset.top = topContentAdditionalInset
            collectionView.contentInset = contentInset
            collectionView.scrollIndicatorInsets = contentInset
        }
    }
    
    private func showPickerController(_ pickerController: UIImagePickerController,
                                      withSourceType sourceType: UIImagePickerController.SourceType) {
        pickerController.sourceType = sourceType
        
        let show: (UIImagePickerController) -> Void = { [weak self] (pickerController) in
            DispatchQueue.main.async {
                pickerController.sourceType = sourceType
                self?.present(pickerController, animated: true, completion: nil)
                self?.setupBarButtonsEnabled(left: false, right: false)
            }
        }
        
        let accessDenied: (_ withSourceType: UIImagePickerController.SourceType) -> Void = { [weak self] (sourceType) in
            let typeName = sourceType == .camera ? "Camera" : "Photos"
            let title = "\(typeName) Access Disabled"
            let message = "You can allow access to \(typeName) in Settings"
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:])
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        //Check Access
        if sourceType == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
                
            @unknown default:
                break
            }
        }
        else {
            //Photo Library Access
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            @unknown default:
                break
            }
        }
    }
    
    private func showAttachmentBar(with image: UIImage) {
        view.addSubview(attachmentBar)
        attachmentBar.delegate = self
        attachmentBar.translatesAutoresizingMaskIntoConstraints = false
        attachmentBar.leftAnchor.constraint(equalTo: composeWrapper.leftAnchor).isActive = true
        attachmentBar.rightAnchor.constraint(equalTo: composeWrapper.rightAnchor).isActive = true
        attachmentBar.bottomAnchor.constraint(equalTo: composeWrapper.topAnchor).isActive = true
        attachmentBar.heightAnchor.constraint(equalToConstant: attachmentBarHeight).isActive = true
        
        attachmentBar.uploadAttachmentImage(image, sourceType: pickerController.sourceType)
        attachmentBar.cancelButton.isHidden = true
        collectionBottomConstant = attachmentBarHeight
        isUploading = true
        setupBarButtonsEnabled(left: false, right: false)
        
    }
    
    private func hideAttacnmentBar() {
        attachmentBar.removeFromSuperview()
        attachmentBar.imageView.image = nil
        collectionBottomConstant = 0.0
        collectionBottomConstraint.constant = collectionBottomConstant
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func createAttachmentMessage(with attachment: QBChatAttachment, fileSize: CGSize) -> QBChatMessage {
        let message = QBChatMessage.markable()
        message.text = "[Attachment]"
        message.senderID = senderID
        message.dialogID = dialogID
        message.deliveredIDs = [(NSNumber(value: senderID))]
        message.readIDs = [(NSNumber(value: senderID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        message.customParameters[G.file_size] = "\(fileSize.width)_\(fileSize.height)"
        message.attachments = [attachment]
        return message
    }
    
    func didPressAccessoryButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.showPickerController(self.pickerController, withSourceType: .camera)
        }))
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.showPickerController(self.pickerController, withSourceType: .photoLibrary)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alertController.popoverPresentationController {
            // iPad support
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func didPressSend(_ button: UIButton) {
        
        if let attacmentMessage = attachmentMessage, isUploading == false {
            send(withAttachmentMessage: attacmentMessage)
        }
        if let messageText = currentlyComposedMessageText(), messageText.isEmpty == false {
            send(withMessageText: messageText)
        }
    }
    
    private func send(withAttachmentMessage attachmentMessage: QBChatMessage) {
        hideAttacnmentBar()
        sendMessage(message: attachmentMessage)
    }
    
    private func send(withMessageText text: String) {
        let message = QBChatMessage.markable()
        message.text = text
        message.senderID = senderID
        message.dialogID = dialogID
        message.deliveredIDs = [(NSNumber(value: senderID))]
        message.readIDs = [(NSNumber(value: senderID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        sendMessage(message: message)
    }
    
    private func sendMessage(message: QBChatMessage) {
        chatManager.send(message, to: dialog) { [weak self] (error) in
            if let error = error {
                debugPrint("[ChatViewController] sendMessage error: \(error.localizedDescription)")
                return
            }
            self?.dataSource.addMessage(message)
            self?.finishSendingMessage(animated: true)
        }
    }
    
    private func currentlyComposedMessageText() -> String? {
        //  auto-accept any auto-correct suggestions
        if let inputDelegate = messageField.inputDelegate {
            inputDelegate.selectionWillChange(messageField)
            inputDelegate.selectionDidChange(messageField)
        }
        return messageField.text?.stringByTrimingWhitespace()
    }
    
    
    // MARK: - Notifications
    
    private func registerForNotifications(_ registerForNotifications: Bool) {
        let defaultCenter = NotificationCenter.default
        if registerForNotifications {
            defaultCenter.addObserver(self,
                                      selector: #selector(didReceiveMenuWillShow(notification:)),
                                      name: UIMenuController.willShowMenuNotification,
                                      object: nil)
            
            defaultCenter.addObserver(self,
                                      selector: #selector(didReceiveMenuWillHide(notification:)),
                                      name: UIMenuController.willHideMenuNotification,
                                      object: nil)
        } else {
            defaultCenter.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
            defaultCenter.removeObserver(self, name: UIMenuController.willHideMenuNotification, object: nil)
        }
    }
    
    @objc private func didReceiveMenuWillShow(notification: NSNotification) {
        guard let selectedIndexPath = selectedIndexPathForMenu,
            let menu = notification.object as? UIMenuController,
//            let selectedCell = chatsTableView.cellForRow(at: selectedIndexPath)
            let selectedCell = collectionView.cellForItem(at: selectedIndexPath)
        else {
            return
        }
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
        
        menu.setMenuVisible(false, animated: false)
        
        let selectedMessageBubbleFrame = selectedCell.convert(selectedCell.contentView.frame, to: view)
        
        menu.setTargetRect(selectedMessageBubbleFrame, in: view)
        menu.setMenuVisible(true, animated: true)
        
        defaultCenter.addObserver(self,
                                  selector: #selector(didReceiveMenuWillShow(notification:)),
                                  name: UIMenuController.willShowMenuNotification,
                                  object: nil)
    }
    
    @objc private func didReceiveMenuWillHide(notification: NSNotification) {
        if selectedIndexPathForMenu == nil {
            return
        }
        
        selectedIndexPathForMenu = nil
    }
    
    
    // MARK - Orientation
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil,
                            completion: { [weak self] (context) in
                                self?.updateCollectionViewInsets()
        })
        
        if messageField.isFirstResponder,
            let splitViewController = splitViewController,
            splitViewController.isCollapsed == false {
            messageField.resignFirstResponder()
        }
    }
    
    
    private func getChatMessageType(message: QBChatMessage) -> ChatMessageType {
        if message.customParameters["notification_type"] != nil || message.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            return .Notification
        }
        
        if message.senderID == senderID {
            return .Outgoing
        }
        else {
            if let messageText = message.text, !messageText.isEmpty {
                return .Incoming
            }
            else {
                return .TypingNow
            }
        }
    }
    
    private func getCellIdentifier(type: ChatMessageType) -> String {
        var cellIdentifier = ""
        switch type {
        case .TypingNow:
            cellIdentifier = "TypingNowCell"
            break
        case .Notification:
            cellIdentifier = "NotificationMessageCell"
            break
        case .Incoming:
            cellIdentifier = "IncomingMessageCell"
            break
        case .Outgoing:
            cellIdentifier = "OutgoingMessageCell"
            break
        }
        return cellIdentifier
    }
    
    
    // MARK: - API functions
    
    func getAllDetailsUser(userId: String) {
        SVProgressHUD.show()
        AppWebClient.GetAllDetailsUser(userId: userId) { (json) in
            
            guard let response = json else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "Failed to call GetAllDetailsUser api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            let valueArray = response[G.response].arrayObject
            if (valueArray != nil && valueArray!.count > 0) {
                self.userInfo = valueArray![0] as? [String: Any]
                self.refreshUserInfo()
            }
        }
    }
}


extension ChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = dataSource.messages.count
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return 0.0
        }
        
        guard let messageText = message.text, !messageText.isEmpty else {
            return 95.0
        }
        
        var cellHeight = messageText.getMessageHeight() + 20.0 + 10.0
        
        print("message = \(messageText) : \(AppShared.getDateString(from: message.dateSent!, format: "yyyy-MM-dd HH:mm:ss")) : \(cellHeight)")
        
        let messageType = getChatMessageType(message: message)
        if (messageType == .Incoming) {
            cellHeight = cellHeight + 35.0
        }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "TypingNowCell", for: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "TypingNowCell") as! MessageCell
        
        // Configure the cell...
        
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return cell
        }
        
        let messageType = getChatMessageType(message: message)
        switch messageType {
        case .TypingNow:
            cell = tableView.dequeueReusableCell(withIdentifier: "TypingNowCell", for: indexPath) as! TypingNowCell
            break
        case .Notification:
            cell = tableView.dequeueReusableCell(withIdentifier: "NotificationMessageCell", for: indexPath) as! NotificationMessageCell
            break
        case .Incoming:
            cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMessageCell", for: indexPath) as! IncomingMessageCell
//            cell.userImageView.image = UIImage(named: message.lawyer!.imageUrl!)
            break
        case .Outgoing:
            cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingMessageCell", for: indexPath) as! OutgoingMessageCell
            break
        }

        if let messageText = message.text, !messageText.isEmpty {
            cell.messageLabel.text = messageText
        }
//        cell.timeLabel.text = message.time!
//
//        let size = message.getMessageSize()
//        if (message.image != nil) {
//            cell.messageWrapperWidth.constant = size.width + 20.0
//
//            cell.messageImageView.image = message.image
//            cell.messageImageView.isHidden = false
//        }
//        else {
//            cell.messageWrapperWidth.constant = size.width + 30.0
//
//            cell.messageImageView.isHidden = true
//        }
//        self.view.layoutIfNeeded()
        
        return cell
    }
}


extension ChatVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}


// MARK: - UIImagePickerControllerDelegate

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /*
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.sendPhoto(image: image)
            }
        }
        else{
            print("Something went wrong")
        }
    }
    */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else {
            return
        }
        setupBarButtonsEnabled(left: false, right: false)
        showAttachmentBar(with: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Helper function.
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})}
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        setupBarButtonsEnabled(left: true, right: false)
    }
}


// MARK: - UIScrollViewDelegate

extension ChatVC: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        // disabling scroll to bottom when tapping status bar
        return false
    }
}


// MARK: - ChatDataSourceDelegate

extension ChatVC: ChatDataSourceDelegate {
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        willChangeWithMessageIDs IDs: [String]) {
        IDs.forEach{ collectionView.chatCollectionViewLayout?.removeSizeFromCache(forItemID: $0) }
    }
    
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        changeWithMessages messages: [QBChatMessage],
                        action: ChatDataSourceAction) {
        if messages.isEmpty {
            return
        }
        
        /*
        chatsTableView.performBatchUpdates({ [weak self] in
            guard let self = self else {
                return
            }
            
            let indexPaths = chatDataSource.performChangesFor(messages: messages, action: action)
            
            if indexPaths.isEmpty {
                return
            }
            
            switch action {
            case .add: self.chatsTableView.insertRows(at: indexPaths, with: .fade)
            case .update: self.chatsTableView.reloadRows(at: indexPaths, with: .fade)
            case .remove: self.chatsTableView.deleteRows(at: indexPaths, with: .fade)
            }
        }, completion: nil)
        */
        
        collectionView.performBatchUpdates({ [weak self] in
            guard let self = self else {
                return
            }
            
            let indexPaths = chatDataSource.performChangesFor(messages: messages, action: action)
            
            if indexPaths.isEmpty {
                return
            }
            
            switch action {
            case .add: self.collectionView.insertItems(at: indexPaths)
            case .update: self.collectionView.reloadItems(at: indexPaths)
            case .remove: self.collectionView.deleteItems(at: indexPaths)
            }
            
        }, completion: nil)
    }
}


// MARK: - UICollectionViewDelegate

extension ChatVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        selectedIndexPathForMenu = indexPath
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        canPerformAction action: Selector,
                        forItemAt indexPath: IndexPath,
                        withSender sender: Any?) -> Bool {
        if action != #selector(copy(_:)) {
            return false
        }
        guard let item = dataSource.messageWithIndexPath(indexPath) else {
            return false
        }
        if self.viewClass(forItem: item) === ChatNotificationCell.self {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return
        }
        if message.attachments?.isEmpty == false {
            return
        }
        UIPasteboard.general.string = message.text
    }
}


// MARK: - ChatCollectionViewDataSource

extension ChatVC: ChatCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.messages.count
        let count = dataSource.messages.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:ChatEmptyCell.self),
                                                      for: indexPath)
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return cell
        }
        
        let cellClass = viewClass(forItem: message)
        
        guard let identifier = cellClass.cellReuseIdentifier() else {
            return cell
        }
        
        let chatCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                          for: indexPath)
        
        if let chatCollectionView = collectionView as? ChatCollectionView {
            self.collectionView(chatCollectionView, configureCell: chatCell, for: indexPath)
        }
        
        let lastSection = collectionView.numberOfSections - 1
        let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        
        if indexPath.section == lastSection,
            indexPath.item == lastItem,
            cancel == false  {
            loadMessages(with: dataSource.loadMessagesCount)
        }
        
        return chatCell
    }
    
    func collectionView(_ collectionView: ChatCollectionView, itemIdAt indexPath: IndexPath) -> String {
        guard let message = dataSource.messageWithIndexPath(indexPath), let ID = message.id else {
            return "0"
        }
        return ID
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // marking message as read if needed
        if isDeviceLocked == true {
            return
        }
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return
        }
        if message.readIDs?.contains(NSNumber(value: senderID)) == false {
            chatManager.read([message], dialog: dialog, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let item = dataSource.messageWithIndexPath(indexPath),
            let attachment = item.attachments?.first,
            let attachmentID = attachment.id else {
                return
        }
        let attachmentDownloadManager = AttachmentDownloadManager()
        attachmentDownloadManager.slowDownloadAttachment(attachmentID)
    }
    
    private func collectionView(_ collectionView: ChatCollectionView,
                                configureCell cell: UICollectionViewCell,
                                for indexPath: IndexPath) {
        
        guard let item = dataSource.messageWithIndexPath(indexPath) else {
            return
        }
        
        if let notificationCell = cell as? ChatNotificationCell {
            notificationCell.isUserInteractionEnabled = false
            notificationCell.notificationLabel.attributedText = attributedString(forItem: item)
            return
        }
        
        guard let chatCell = cell as? ChatCell else {
            return
        }
        
        if cell is ChatIncomingCell || cell is ChatOutgoingCell {
            chatCell.textView.enabledTextCheckingTypes = enableTextCheckingTypes
        }
        
        if let textView = chatCell.textView {
            textView.text = attributedString(forItem: item)
        }
        
        chatCell.delegate = self
        
        if let attachmentCell = cell as? ChatAttachmentCell {
            
            guard let attachment = item.attachments?.first,
                let attachmentID = attachment.id,
                attachment.type == "image" else {
                    return
            }
            //setup image to attachmentCell
            attachmentCell.setupAttachmentWithID(attachmentID)
            
            if attachmentCell is ChatAttachmentIncomingCell {
                print("===============> \(chatCell.containerView.frame)")
                chatCell.loadAvatar(image: recipientAvatar, imageUrl: recipientAvatarUrl)
            }
            else if attachmentCell is ChatAttachmentOutgoingCell {
                print("===============> \(chatCell.containerView.frame)")
//                chatCell.loadAvatar(image: currentUserAvatar, imageUrl: AppShared.getProfileUrl())
            }
            
        }
        else if chatCell is ChatIncomingCell {
            chatCell.loadAvatar(image: recipientAvatar, imageUrl: recipientAvatarUrl)
        }
        else if chatCell is ChatOutgoingCell {
//            chatCell.loadAvatar(image: currentUserAvatar, imageUrl: AppShared.getProfileUrl())
        }
    }
}


// MARK: - ChatCollectionViewDelegateFlowLayout

extension ChatVC: ChatCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chatLayout = collectionViewLayout as? ChatCollectionViewFlowLayout else {
            return .zero
        }
        return chatLayout.sizeForItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: ChatCollectionView, layoutModelAt indexPath: IndexPath) -> ChatCellLayoutModel {
        guard let item = dataSource.messageWithIndexPath(indexPath),
            let _ = item.id,
            let cellClass = viewClass(forItem: item) as? ChatCellProtocol.Type else {
                return ChatCell.layoutModel()
        }
        var layoutModel = cellClass.layoutModel()

        layoutModel.avatarSize = .zero

//        if cellClass == ChatIncomingCell.self || cellClass == ChatAttachmentIncomingCell.self {
////            if dialog.type != .private {
//                layoutModel.avatarSize = CGSize(width: 30.0, height: 30.0)
//                layoutModel.containerMarginLeft = 30.0
////            }
//        }
        
        
        if cellClass == ChatIncomingCell.self || cellClass == ChatAttachmentIncomingCell.self {
            layoutModel.avatarSize = CGSize(width: 30.0, height: 30.0)
            layoutModel.containerMarginLeft = 30.0
        }
        else if cellClass == ChatOutgoingCell.self || cellClass == ChatAttachmentOutgoingCell.self {
        }
        else if cellClass == ChatNotificationCell.self {
        }

        return layoutModel
    }
    
    func collectionView(_ collectionView: ChatCollectionView,
                        minWidthAt indexPath: IndexPath) -> CGFloat {
        guard let item = dataSource.messageWithIndexPath(indexPath),
            let _ = item.id else {
                return 0.0
        }
        
        let frameWidth = collectionView.frame.width
        let constraintsSize = CGSize(width:frameWidth * 0.8,
                                     height: .greatestFiniteMagnitude)
        
        let attributedString = bottomLabelAttrString(forItem: item)
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: constraintsSize, limitedToNumberOfLines:0)
        
        return size.width
    }
    
    func collectionView(_ collectionView: ChatCollectionView, dynamicSizeAt indexPath: IndexPath, maxWidth: CGFloat) -> CGSize {
        var size: CGSize = .zero
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return size
        }
        
        let messageCellClass = viewClass(forItem: message)
        if messageCellClass === ChatAttachmentIncomingCell.self {
            size = CGSize(width: min(200, maxWidth), height: 200)
            if let strFileSize = message.customParameters![G.file_size] {
                let compoments = (strFileSize as! String).split(separator: "_")
                let width = NumberFormatter().number(from: String(compoments[0])) as! CGFloat
                let height = NumberFormatter().number(from: String(compoments[1])) as! CGFloat
                size = CGSize(width: width, height: height)
                size = size.getFitSizeFotChatImage()
            }
        }
        else if messageCellClass === ChatAttachmentOutgoingCell.self {
            size = CGSize(width: min(200, maxWidth), height: 200)
            if let strFileSize = message.customParameters![G.file_size] {
                let compoments = (strFileSize as! String).split(separator: "_")
                let width = NumberFormatter().number(from: String(compoments[0])) as! CGFloat
                let height = NumberFormatter().number(from: String(compoments[1])) as! CGFloat
                size = CGSize(width: width, height: height)
                size = size.getFitSizeFotChatImage()
            }
        }
        else if messageCellClass === ChatNotificationCell.self {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString,
                                                                   withConstraints: CGSize(width: maxWidth,
                                                                                           height: CGFloat.greatestFiniteMagnitude),
                                                                   limitedToNumberOfLines: 0)
        }
        else {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString,
                                                                   withConstraints: CGSize(width: maxWidth,
                                                                                           height: CGFloat.greatestFiniteMagnitude),
                                                                   limitedToNumberOfLines: 0)
            size = CGSize(width: size.width, height: max(30.0, size.height))
        }
        return size
    }
}

/*
// MARK: - UITextViewDelegate

extension ChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView {
            return
        }
        if automaticallyScrollsToMostRecentMessage == true {
            collectionBottomConstraint.constant = collectionBottomConstant
            scrollToBottomAnimated(true)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView {
            return
        }
        if isUploading == true || attachmentMessage != nil {
            inputToolbar.setupBarButtonsEnabled(left: false, right: true)
        } else {
            inputToolbar.setupBarButtonsEnabled(left: true, right: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView {
            return
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length + range.location > textView.text.count {
            return false
        }
        return true
    }
}
*/

// MARK: - UITextFieldDelegate

extension ChatVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField != messageField {
            return
        }
        if automaticallyScrollsToMostRecentMessage == true {
            collectionBottomConstraint.constant = collectionBottomConstant
            scrollToBottomAnimated(true)
        }
    }
    
    /*
    func textFieldDidChange(_ textField: UITextField) {
        if textField != messageField {
            return
        }
        
        if isUploading == true || attachmentMessage != nil {
            setupBarButtonsEnabled(left: false, right: true)
        }
        else {
            setupBarButtonsEnabled(left: true, right: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField != messageField {
            return
        }
    }
    */
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > textField.text!.count {
            return false
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
           
            if isUploading == true || attachmentMessage != nil {
                setupBarButtonsEnabled(left: false, right: updatedText.count > 0)
            }
            else {
                setupBarButtonsEnabled(left: true, right: updatedText.count > 0)
            }
        }
        
        return true
    }
}


// MARK: - ChatCellDelegate

extension ChatVC: ChatCellDelegate {
    
    private func handleNotSentMessage(_ message: QBChatMessage,
                                      forCell cell: ChatCell) {
        
        let alertController = UIAlertController(title: "", message: "MESSAGE_FAILED_TO_SEND".localized, preferredStyle:.actionSheet)
        
        let resend = UIAlertAction(title: "TRY_AGAIN_MESSAGE".localized, style: .default) { (action) in
        }
        alertController.addAction(resend)
        
        let delete = UIAlertAction(title: "DELETE_MESSAGE".localized, style: .destructive) { (action) in
            
            self.dataSource.deleteMessage(message)
        }
        alertController.addAction(delete)
        
        let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel) { (action) in
        }
        
        alertController.addAction(cancelAction)
        
        if alertController.popoverPresentationController != nil {
            view.endEditing(true)
            alertController.popoverPresentationController!.sourceView = cell.containerView
            alertController.popoverPresentationController!.sourceRect = cell.containerView.bounds
        }
        
        self.present(alertController, animated: true) {
        }
    }
    
    func chatCellDidTapAvatar(_ cell: ChatCell) {
    }
    
    private func openZoomVC(image: UIImage) {
        let zoomedVC = ZoomedAttachmentVC()
        zoomedVC.zoomImageView.image = image
        zoomedVC.modalPresentationStyle = .overCurrentContext
        zoomedVC.modalTransitionStyle = .crossDissolve
        present(zoomedVC, animated: true, completion: nil)
    }
    
    func chatCellDidTapContainer(_ cell: ChatCell) {
        if let attachmentCell = cell as? ChatAttachmentCell, let attachmentImage = attachmentCell.attachmentImageView.image {
            self.openZoomVC(image: attachmentImage)
        }
    }
    func chatCell(_ cell: ChatCell, didTapAtPosition position: CGPoint) {}
    func chatCell(_ cell: ChatCell, didPerformAction action: Selector, withSender sender: Any) {}
    func chatCell(_ cell: ChatCell, didTapOn result: NSTextCheckingResult) {
        
        switch result.resultType {
        case NSTextCheckingResult.CheckingType.link:
            guard let strUrl = result.url?.absoluteString else {
                return
            }
            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")
            if hasPrefix == true {
                guard let url = URL(string: strUrl) else {
                    return
                }
                let controller = SFSafariViewController(url: url)
                present(controller, animated: true, completion: nil)
            }
        case NSTextCheckingResult.CheckingType.phoneNumber:
            if canMakeACall() == false {
                SVProgressHUD.showInfo(withStatus: "Your Device can't make a phone call".localized)
                break
            }
            view.endEditing(true)
            let alertController = UIAlertController(title: "",
                                                    message: result.phoneNumber,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "CALL".localized, style: .destructive) { (action) in
                if let phoneNumber = result.phoneNumber,
                    let url = URL(string: "tel:" + phoneNumber) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            alertController.addAction(openAction)
            present(alertController, animated: true) {
            }
        default:
            break
        }
    }
    
    private func canMakeACall() -> Bool {
        var canMakeACall = false
        if let url = URL.init(string: "tel://"), UIApplication.shared.canOpenURL(url) == true {
            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            guard let carrier = networkInfo.subscriberCellularProvider else {
                return false
            }
            let mobileNetworkCode = carrier.mobileNetworkCode
            if mobileNetworkCode?.isEmpty == true {
                // Device cannot place a call at this time.  SIM might be removed.
            } else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        } else {
            // iOS Device is not capable for making calls
        }
        return canMakeACall
    }
}


// MARK: - QBChatDelegate

extension ChatVC: QBChatDelegate {
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        if senderID == readerID || dialogID != self.dialogID {
            return
        }
        guard let message = dataSource.messageWithID(messageID) else {
            return
        }
        print("=====> chatDidReadMessage: \(message.text!)")
        
        message.readIDs?.append(NSNumber(value: readerID))
        dataSource.updateMessage(message)
    }
    
    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        if senderID == userID || dialogID != self.dialogID {
            return
        }
        guard let message = dataSource.messageWithID(messageID) else {
            return
        }
        
        message.deliveredIDs?.append(NSNumber(value: userID))
        dataSource.updateMessage(message)
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        if message.dialogID == self.dialogID {
            dataSource.addMessage(message)
        }
    }
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        if dialogID == self.dialogID {
            dataSource.addMessage(message)
        }
    }
    
    func chatDidConnect() {
        refreshAndReadMessages()
    }
    
    func chatDidReconnect() {
        refreshAndReadMessages()
    }
    
    //MARK - Help
    private func refreshAndReadMessages() {
        SVProgressHUD.show(withStatus: "LOADING_MESSAGES".localized)
        loadMessages()
    }
}


// MARK: - AttachmentBarDelegate

extension ChatVC: AttachmentBarDelegate {
    func attachmentBarFailedUpLoadImage(_ attachmentBar: AttachmentBar) {
        cancelUploadFile()
    }
    
    func attachmentBar(_ attachmentBar: AttachmentBar, didUpLoadAttachment attachment: QBChatAttachment, fileSize: CGSize) {
        attachmentMessage = createAttachmentMessage(with: attachment, fileSize: fileSize)
        isUploading = false
        setupBarButtonsEnabled(left: false, right: true)
    }
    
    func attachmentBar(_ attachmentBar: AttachmentBar, didTapCancelButton: UIButton) {
        attachmentMessage = nil
        setupBarButtonsEnabled(left: true, right: false)
        hideAttacnmentBar()
    }
}
