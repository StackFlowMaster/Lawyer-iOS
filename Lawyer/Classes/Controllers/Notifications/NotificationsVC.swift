//
//  NotificationsVC.swift
//  Lawyer
//
//  Created by Admin on 11/1/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var notificationsTableViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    func initUI() {
        self.tabBarController?.tabBar.isHidden = true
        
        self.title = "Notifications"
        
    }
    
    func updateWrapper() {
        self.notificationsTableViewBottom.constant = self.view.frame.width * 100.0 / 375.0 - 20.0
        self.view.layoutIfNeeded()
    }
    
    func loadNotifications() {
        let accountType = AppShared.getAccountType()
        if (accountType == .Lawyer) {
            getLawyerNotifications()
        }
        else if (accountType == .User) {
            getUserNotifications()
        }
    }
    
    func goToAppointment(notification: Notification) {

        let mainTabVC = AppManager.shared.mainTabVC
        let appointmentsNVC: AppointmentsNVC = mainTabVC.viewControllers![1] as! AppointmentsNVC
        if let appointmentsVC: AppointmentsVC = appointmentsNVC.topViewController as? AppointmentsVC {
            appointmentsVC.notificationToBeShown = notification
        }
        mainTabVC.tapTabButton(mainTabVC.tabButtonAppointment)
        
        let accountType = AppShared.getAccountType()
        if (accountType == .Lawyer) {
            readLawyerNotification(notificationId: notification.notificationId!)
        }
        else if (accountType == .User) {
            readUserNotification(notificationId: notification.notificationId!)
        }
    }
    
    
    // MARK: - API functions
    
    func getLawyerNotifications() {
        
        SVProgressHUD.show()
        AppWebClient.GetLawyerNotification() { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetLawyerNotification api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string!)
                return;
            }
            
            guard let jsonNotifications = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.notifications = [Notification]()
            for info in jsonNotifications {
                let notification = Mapper<Notification>().map(JSONString: info.rawString()!)
                self.notifications.append(notification!)
            }
            self.notificationsTableView.reloadData()
            
            self.showNoResultLabel(label: self.noResultLabel, show: self.notifications.count < 1, message: G.No_record_found)
        }
    }
    
    func getUserNotifications() {
        
        SVProgressHUD.show()
        AppWebClient.GetUserNotification() { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetUserNotification api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string!)
                return;
            }
            
            guard let jsonNotifications = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.notifications = [Notification]()
            for info in jsonNotifications {
                let notification = Mapper<Notification>().map(JSONString: info.rawString()!)
                self.notifications.append(notification!)
            }
            self.notificationsTableView.reloadData()
            
            self.showNoResultLabel(label: self.noResultLabel, show: self.notifications.count < 1, message: G.No_record_found)
        }
    }
    
    func readLawyerNotification(notificationId: String) {
        
        SVProgressHUD.show()
        AppWebClient.ReadLawyerNotification(notificationId: notificationId) { (json) in
            SVProgressHUD.dismiss()
        }
    }
    
    func readUserNotification(notificationId: String) {
        
        SVProgressHUD.show()
        AppWebClient.ReadUserNotification(notificationId: notificationId) { (json) in
            SVProgressHUD.dismiss()
        }
    }
}


extension NotificationsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        // Configure the cell...
        
        let notification = self.notifications[indexPath.row]
        cell.nameLabel.text = notification.fullName!
        cell.timeLabel.text = "\(notification.appointmentDate!) \(notification.time!)"
        
        if let userImageUrl = notification.userImageUrl, !userImageUrl.isEmpty {
            cell.userImageView.sd_setImage(with: URL(string: userImageUrl), completed: nil)
        }
        else {
            cell.userImageView.image = UIImage(named: "ic_avatar_1")
        }
        cell.selectionStyle = .none
        
        return cell
    }
}


extension NotificationsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = self.notifications[indexPath.row]
        goToAppointment(notification: notification)
    }
}
