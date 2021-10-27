//
//  LawyerTabVC.swift
//  Lawyer
//
//  Created by Admin on 11/1/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class LawyerTabVC: UITabBarController {

    @IBOutlet var tabView: UIView!
    @IBOutlet var tabWrapper: UIView!
    @IBOutlet weak var tabBgView: UIImageView!
    @IBOutlet weak var tabButtonHome: UIButton!
    @IBOutlet weak var tabButtonAppointment: UIButton!
    @IBOutlet weak var tabButtonNotification: UIButton!
    @IBOutlet weak var tabButtonMessages: UIButton!
    @IBOutlet weak var tabButtonProfile: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        (UIApplication.shared.delegate as! AppDelegate).mainTabVC = self
        
        let accountType = AppShared.getAccountType()
        
        tapTabButton((accountType == .Lawyer) ? tabButtonProfile : tabButtonHome)
        
        tabButtonHome.isUserInteractionEnabled = (accountType != .Lawyer)
        tabButtonAppointment.isUserInteractionEnabled = (accountType != .Guest)
        tabButtonNotification.isUserInteractionEnabled = (accountType != .Guest)
        tabButtonMessages.isUserInteractionEnabled = (accountType != .Guest)
        tabButtonProfile.isUserInteractionEnabled = (accountType != .Guest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showTabView(show: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showTabView(show: Bool) {
        let width = self.view.frame.width
        let height = width * 100.0 / 375.0
        
        if (show) {
            if (self.tabView.superview != self.view) {
                self.view.addSubview(self.tabView)
                self.tabView.frame = CGRect(x: 0.0, y: self.view.frame.height - height, width: width, height: height)
                
                self.view.bringSubviewToFront(self.tabView)
            }
        }
        else {
            if (self.tabView.superview == self.view) {
                self.view.sendSubviewToBack(self.tabView)
                self.tabView.removeFromSuperview()
            }
        }
    }

    @IBAction func tapTabButton(_ sender: UIButton) {
        self.tabButtonHome.isSelected = sender == self.tabButtonHome
        self.tabButtonAppointment.isSelected = sender == self.tabButtonAppointment
        self.tabButtonNotification.isSelected = sender == self.tabButtonNotification
        self.tabButtonMessages.isSelected = sender == self.tabButtonMessages
        self.tabButtonProfile.isSelected = sender == self.tabButtonProfile
        
        switch sender.tag {
        case G.TabItem.Home.rawValue:
            tabBgView.image = UIImage(named: "bg_tab_home")
            break
        case G.TabItem.Appointment.rawValue:
            tabBgView.image = UIImage(named: "bg_tab_appointments")
            break
        case G.TabItem.Notification.rawValue:
            tabBgView.image = UIImage(named: "bg_tab_notifications")
            break
        case G.TabItem.Messages.rawValue:
            tabBgView.image = UIImage(named: "bg_tab_messages")
            break
        case G.TabItem.Profile.rawValue:
            tabBgView.image = UIImage(named: "bg_tab_profile")
            break
        default:
            break
        }
        
        self.selectedIndex = sender.tag
    }
    
    func getTopVC() -> UIViewController? {
//        var topVC = (self.selectedViewController as! UINavigationController).topViewController
//        if let presentedVC = (self.selectedViewController as! UINavigationController).presentedViewController {
//            topVC = presentedVC
//        }
        
        var topVC = (self.selectedViewController as! UINavigationController).topViewController
        if var topController = topVC {
            while let presentedVC = topController.presentedViewController {
                topController = presentedVC
            }

            // topController should now be your topmost view controller
            topVC = topController
        }
        
        print("==========> topVC = \(String(describing: topVC))")
        return topVC
    }
    
    func presentAudioCallVC() {
        if let topVC = self.getTopVC(), topVC is AudioCallVC {
            return
        }
        
        if let audioCallVC = self.storyboard?.instantiateViewController(withIdentifier: "AudioCallVC") as? AudioCallVC {
            audioCallVC.isPresented = true
            
//            let nav = UINavigationController(rootViewController: audioCallVC)
//            nav.modalTransitionStyle = .crossDissolve
//            self.present(nav , animated: false)
            
            audioCallVC.modalTransitionStyle = .crossDissolve
            self.present(audioCallVC , animated: false)
        }
    }
    
    func dismissCallVC() {
        guard let topVC = self.getTopVC(), topVC is CallVC else {
            return
        }
        
//        topVC.dismiss(animated: true, completion: nil)
        
        if (topVC as! CallVC).isPresented {
            topVC.dismiss(animated: true, completion: nil)
        }
        else {
            topVC.navigationController?.popViewController(animated: true)
        }
    }
}


extension LawyerTabVC: UITabBarControllerDelegate {
    
}
