//
//  VideoCallVC.swift
//  Lawyer
//
//  Created by Admin on 11/7/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class VideoCallVC: CallVC {

    @IBOutlet weak var buttonWrapper: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarController = self.tabBarController {
            (tabBarController as! LawyerTabVC).showTabView(show: false)
        }
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
        self.navigationController?.clear()
        
//        self.title = self.lawyer!.full_name
//        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
//        self.largeImageView.image = UIImage(named: self.lawyer!.imageUrl!)
    }
}
