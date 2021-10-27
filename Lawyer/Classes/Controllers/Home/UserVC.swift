//
//  UserVC.swift
//  Lawyer
//
//  Created by Admin on 11/7/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Cosmos

class UserVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    
    @IBOutlet weak var profileWrapper: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lawyerLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var reviewWrapper: UIView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var consultsLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var descView: UITextView!
    
    @IBOutlet weak var actionWrapper: UIView!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    var lawyer: Lawyer?
    private var lawyerzInfo: [String: Any]?
    
    private let chatManager = ChatManager.instance
    private var qbUser: QBUUser?
    
    var recipientAvatarUrl: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
        
        getAllDetailsLawyer(lawyerId: lawyer!.lawyerId!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
        
//        (self.tabBarController as! LawyerTabVC).showTabView(show: true)
        AppManager.shared.mainTabVC.showTabView(show: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ShowAudioCallVC") {
            let vc = segue.destination as! AudioCallVC
            vc.lawyerzInfo = self.lawyerzInfo
            vc.remoteUser = self.qbUser
        }
        else if (segue.identifier == "ShowVideoCallVC") {
            let vc = segue.destination as! VideoCallVC
            vc.lawyerzInfo = self.lawyerzInfo
            vc.remoteUser = self.qbUser
        }
        else if (segue.identifier == "ShowChatVC") {
            let vc = segue.destination as! ChatVC
            vc.dialogID = sender as? String
            vc.recipientAvatarUrl = recipientAvatarUrl
        }
        else if (segue.identifier == "ShowSetDateVC") {
            let vc = segue.destination as! SetDateVC
            vc.lawyerId = self.lawyer?.lawyerId
        }
        
    }
    
    
    // MARK: - UI functions
    
    func initUI() {
        self.navigationController?.clear()
        
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.borderColor = UIColor.green.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        
        self.statusImageView.layer.borderWidth = 2.0
        self.statusImageView.layer.borderColor = UIColor.white.cgColor
        self.statusImageView.layer.cornerRadius = self.statusImageView.frame.height / 2

        self.ratingView.isUserInteractionEnabled = false
        self.ratingView.alpha = 0.0
        
        self.actionWrapper.shadow()
        
//        self.profileImageView.image = UIImage(named: self.user!.imageUrl!)
        self.profileImageView!.sd_setImage(with: URL(string: lawyer!.imageUrl!), completed: nil)
        self.nameLabel.text = lawyer!.full_name
        self.lawyerLabel.text = lawyer!.lawyerType
        self.ratingView.rating = lawyer!.rating!
        self.statusImageView.image = lawyer!.statusImage
        
        
        // load user with login string
        chatManager.loadUser(lawyer!.lawyerId!) { (user) in
            print("user = \(user?.email ?? "")")
            
            guard let user = user else {
                self.showAlert(msg: "No exist QB account of selected Lawyer")
                return
            }
            
            self.qbUser = user
        }
    }
    
    func updateWrapper() {
        let scrollViewHeight = self.scrollView.frame.height
        let wrapperHeight = self.view.frame.width * 732.0 / 375.0
        if (wrapperHeight > scrollViewHeight) {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: wrapperHeight)
        }
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapMenuButton(_ sender: Any) {
    }
    
    @IBAction func tapActionButton(_ sender: UIButton) {
        let appManager = AppManager.shared
        
        switch sender.tag {
        case G.CommuAction.Audio.rawValue:
            if (AppShared.getAccountType() == .Guest) {
                self.performSegue(withIdentifier: "ShowProfileInfoVC", sender: nil)
                return
            }

            if (qbUser != nil) {
                appManager.dataSource.appendSelectedUser(user: qbUser)
                appManager.call(with: .audio, qbUser: qbUser, lawyerzInfo: lawyerzInfo)
            }
//            self.performSegue(withIdentifier: "ShowAudioCallVC", sender: nil)
            break
            
        case G.CommuAction.Video.rawValue:
            if (AppShared.getAccountType() == .Guest) {
                self.performSegue(withIdentifier: "ShowProfileInfoVC", sender: nil)
                return
            }
            
            if (qbUser != nil) {
                appManager.dataSource.appendSelectedUser(user: qbUser)
                appManager.call(with: .video, qbUser: qbUser, lawyerzInfo: lawyerzInfo)
            }
//            self.performSegue(withIdentifier: "ShowVideoCallVC", sender: nil)
            break
            
        case G.CommuAction.Chat.rawValue:
            moveToChat()
            break
            
        case G.CommuAction.SetDate.rawValue:
            if (AppShared.getAccountType() == .Guest) {
                self.performSegue(withIdentifier: "ShowProfileInfoVC", sender: nil)
                return
            }
            self.performSegue(withIdentifier: "ShowSetDateVC", sender: nil)
            break
            
        case G.CommuAction.Hire.rawValue:
            break
            
        default:
            break
        }
    }
    
    @IBAction func unwindToUserVC(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    func refreshLawyerInfo() {
        if (lawyerzInfo == nil) {
            return
        }
        
        profileImageView.sd_setImage(with: URL(string: lawyerzInfo![G.profile_pic] as! String), completed: nil)
        
        var statusImage = UIImage(named: "ic_status_invisible")
        let status = lawyerzInfo![G.live_status] as? String
        if (status == G.Online) {
            statusImage = UIImage(named: "ic_status_active")
        }
        else if (status == G.Offline) {
            statusImage = UIImage(named: "ic_status_offline")
        }
        statusImageView.image = statusImage
        
        nameLabel.text = lawyerzInfo![G.full_name] as? String
        lawyerLabel.text = lawyerzInfo![G.type] as? String
        ratingView.rating = lawyerzInfo![G.avg_rating] as! Double
        commentsLabel.text = lawyerzInfo![G.comments_count] as? String
        consultsLabel.text = lawyerzInfo![G.consults_count] as? String
        viewsLabel.text = lawyerzInfo![G.view_count] as? String
        descView.text = lawyerzInfo![G.details] as? String
    }
    
    func moveToChat() {
        if (qbUser == nil) {
            return
        }

        self.recipientAvatarUrl = lawyer?.imageUrl
        
        if let dialog = chatManager.storage.privateDialog(opponentID: qbUser!.id) {
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)
            return
        }
        
        SVProgressHUD.show()
        chatManager.createPrivateDialog(withOpponent: qbUser!, completion: { (response, dialog) in
            guard let dialog = dialog else {
                SVProgressHUD.dismiss()
                if let error = response?.error {
                    self.showAlert(msg: error.error?.localizedDescription)
                }
                return
            }
            
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)

            /*
            if let imageUrl = self.lawyer?.imageUrl, !imageUrl.isEmpty {
                dialog.photo = self.lawyer?.imageUrl
                
                QBRequest.update(dialog, successBlock: {(theResponce: QBResponse?, theDialog: QBChatDialog?) in
                    SVProgressHUD.dismiss()
                    
                    self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)
                    
                }, errorBlock: {(theResponse: QBResponse!) in
                    SVProgressHUD.dismiss()
                    
                    self.showAlert(msg: theResponse.error?.error?.localizedDescription) { (action) in
                        self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)
                    }
                })
            }
            else {
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)
            }
            */
        })
    }

    
    // MARK: - API functions
    
    func getAllDetailsLawyer(lawyerId: String) {
        SVProgressHUD.show()
        AppWebClient.GetAllDetailsLawyer(lawyerId: lawyerId) { (json) in
            
            guard let response = json else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "Failed to call GetAllDetailsLawyer api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            let valueArray = response[G.response].arrayObject
            if (valueArray != nil && valueArray!.count > 0) {
                self.lawyerzInfo = valueArray![0] as? [String: Any]
                self.refreshLawyerInfo()
            }
            
            self.addViews()
        }
    }
    
    func addViews() {
        SVProgressHUD.show()
        AppWebClient.AddViews(lawyerId: lawyer!.lawyerId!) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call AddViews api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
        }
    }
}
