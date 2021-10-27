//
//  AudioCallVC.swift
//  Lawyer
//
//  Created by Admin on 11/7/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class AudioCallVC: CallVC {

    @IBOutlet weak var buttonWrapper: UIView!
    
    var progressView: CircularProgressView!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.progressView.center = self.userImageView.center
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
//        
//        self.userImageView.image = UIImage(named: self.lawyer!.imageUrl!)
//        self.nameLabel.text = self.lawyer!.full_name
        
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width:self.userImageView.frame.width + 40.0, height:self.userImageView.frame.height + 40.0))
        self.progressView = CircularProgressView(frame: frame)
        self.progressView.center = self.userImageView.center
        self.view.addSubview(progressView)
    }
}
