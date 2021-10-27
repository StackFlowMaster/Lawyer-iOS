//
//  MessagesVC.swift
//  Lawyer
//
//  Created by Admin on 11/1/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit


//class DialogCellModel: NSObject {
//
//    //MARK: - Properties
//    var textLabelText: String = ""
//    var unreadMessagesCounterLabelText : String?
//    var unreadMessagesCounterHiden = true
//    var dialogIcon : UIImage?
//
//    //MARK: - Life Cycle
//    init(dialog: QBChatDialog) {
//        super.init()
//
//        if let dialogName = dialog.name {
//            textLabelText = dialogName
//        }
//
//        // Unread messages counter label
//        if dialog.unreadMessagesCount > 0 {
//            var trimmedUnreadMessageCount = ""
//
//            if dialog.unreadMessagesCount > 99 {
//                trimmedUnreadMessageCount = "99+"
//            } else {
//                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
//            }
//            unreadMessagesCounterLabelText = trimmedUnreadMessageCount
//            unreadMessagesCounterHiden = false
//        } else {
//            unreadMessagesCounterLabelText = nil
//            unreadMessagesCounterHiden = true
//        }
//        // Dialog icon
//        if dialog.type == .private {
//            dialogIcon = UIImage(named: "user")
//
//            if dialog.recipientID == -1 {
//                return
//            }
//            // Getting recipient from users.
//            if let recipient = ChatManager.instance.storage.user(withID: UInt(dialog.recipientID)),
//                let fullName = recipient.fullName {
//                self.textLabelText = fullName
//            } else {
//                ChatManager.instance.loadUser(UInt(dialog.recipientID)) { [weak self] (user) in
//                    self?.textLabelText = user?.fullName ?? user?.login ?? ""
//                }
//            }
//        } else {
//            self.dialogIcon = UIImage(named: "group")
//        }
//    }
//}

class MessagesVC: UIViewController {

    @IBOutlet weak var headerWrapper: UIView!
    @IBOutlet weak var headerWrapperHeight: NSLayoutConstraint!
    @IBOutlet weak var conversationsTableView: UITableView!
    @IBOutlet weak var conversationsTableViewBottom: NSLayoutConstraint!
    
    var conversations = [Conversation]()
    
    private let chatManager = ChatManager.instance
    private var dialogs: [QBChatDialog] = []

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let  profile = Profile()
        if profile.isFull == true {
//            navigationItem.title = profile.fullName
        }
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        chatManager.delegate = self
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ShowChatVC") {
            let vc = segue.destination as! ChatVC
            
            vc.dialogID = sender as? String
        }
    }

    
    // MARK: - UI functions
    
    func initUI() {
        tabBarController?.tabBar.isHidden = true
        navigationController?.clear()
        
        headerWrapperHeight.constant = appDelegate.topBarHeight
    }
    
    func updateWrapper() {
        headerWrapperHeight.constant = appDelegate.topBarHeight
        conversationsTableViewBottom.constant = self.view.frame.width * 100.0 / 375.0 - 20.0
        view.layoutIfNeeded()
    }
    
    @IBAction func tapMenuButton(_ sender: Any) {
        
    }
    
    func loadConversations() {
    }
    
    func loadTestConversations() {
        self.conversations = [Conversation]()
        
        var messages1 = Message.messageList()
        messages1.append(Message.message1())
        
        var messages2 = Message.messageList()
        messages2.append(Message.message2())
        
        var messages3 = Message.messageList()
        messages3.append(Message.message3())
        
        var messages4 = Message.messageList()
        messages4.append(Message.message4())
        
        
        let conversation1 = Conversation(conversationId: 1)
        conversation1.lawyer = Lawyer.lawyer1()
        conversation1.messages = messages1
        conversations.append(conversation1)
        
        let conversation2 = Conversation(conversationId: 2)
        conversation2.lawyer = Lawyer.lawyer2()
        conversation2.messages = messages2
        conversations.append(conversation2)
        
        let conversation3 = Conversation(conversationId: 3)
        conversation3.lawyer = Lawyer.lawyer3()
        conversation3.messages = messages3
        conversations.append(conversation3)
        
        let conversation4 = Conversation(conversationId: 4)
        conversation4.lawyer = Lawyer.lawyer4()
        conversation4.messages = messages4
        conversations.append(conversation4)
        
        conversationsTableView.reloadData()
    }
    
    // MARK: - Helpers
    private func reloadContent() {
        dialogs = chatManager.storage.dialogsSortByUpdatedAt()
        conversationsTableView.reloadData()
    }
}


extension MessagesVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        
        cell.tag = indexPath.row
        
        // Configure the cell...
        
        let chatDialog = dialogs[indexPath.row]
        cell.nameLabel.text = chatDialog.name
        cell.messageLabel.text = chatDialog.lastMessageText
        let strTime = chatDialog.lastMessageDate?.formatRelativeString()
        cell.timeLabel.text = strTime
        
        if let recipient = chatManager.storage.user(withID: UInt(chatDialog.recipientID)) {
            let blobID = recipient.blobID
            AppManager.shared.downloadQBUserAvatar(blobID) { (avatar) in
                if let avatar = avatar {
                    cell.userImageView.image = avatar
                }
            }
        }
        
        return cell
    }
}


extension MessagesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dialog = dialogs[indexPath.row]
        self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)
    }
}


// MARK: - QBChatDelegate
extension MessagesVC: QBChatDelegate {
    
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        guard let dialogID = message.dialogID else {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        guard let dialogID = message.dialogID else {
            return
        }
        if let _ = chatManager.storage.dialog(withID: dialogID) {
            return
        }
        chatManager.updateDialog(with: dialogID, with: message)
    }
    
    func chatServiceChatDidFail(withStreamError error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatDidAccidentallyDisconnect() {
    }
    
    func chatDidNotConnectWithError(_ error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatDidDisconnectWithError(_ error: Error?) {
    }
    
    func chatDidConnect() {
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
//            SVProgressHUD.showSuccess(withStatus: "CONNECTED".localized, maskType: .clear)
            SVProgressHUD.showSuccess(withStatus: "CONNECTED".localized)
        }
    }
    
    func chatDidReconnect() {
        SVProgressHUD.show(withStatus: "CONNECTED".localized)
        if QBChat.instance.isConnected == true {
            chatManager.updateStorage()
//            SVProgressHUD.showSuccess(withStatus: "CONNECTED".localized, maskType: .clear)
            SVProgressHUD.showSuccess(withStatus: "CONNECTED".localized)
        }
    }
}


// MARK: - ChatManagerDelegate
extension MessagesVC: ChatManagerDelegate {
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog) {
        reloadContent()
        SVProgressHUD.dismiss()
    }
    
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String) {
        reloadContent()
        SVProgressHUD.dismiss()
        QBChat.instance.addDelegate(self)
    }
    
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager) {
        if navigationController?.topViewController == self {
            SVProgressHUD.show()
        }
    }
}
