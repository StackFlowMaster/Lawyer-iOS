//
//  VerificationVC.swift
//  Lawyer
//
//  Created by Admin on 11/8/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class VerificationVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var completeWrapper: UIView!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    var downTimer: Timer?
    var time: Int = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startDownTimer()
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
        self.title = "Verification"
        
        verifyButton.shadow()
        completeButton.shadow()
        completeButton.alpha = 0.0
    }
    
    func updateWrapper() {
        let scrollViewHeight = self.scrollView.frame.height
        let wrapperHeight = self.view.frame.width * 668.0 / 375.0
        if (wrapperHeight > scrollViewHeight) {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: wrapperHeight)
        }
    }
    
    func stopDownTimer() {
        if (downTimer != nil) {
            downTimer?.invalidate()
            downTimer = nil
        }
    }
    
    func startDownTimer() {
        stopDownTimer()
        
        time = 60
        downTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.timeDown()
        })
    }
    
    @objc func timeDown() {
        time = time - 1
        
        guard time > 0 else {
            self.stopDownTimer()
            
            self.timeLabel.text = nil
            self.verifyButton.alpha = 0.0
            self.completeButton.alpha = 0.0
            
            return
        }
        
        timeLabel.text = String(format: "0:%02d", time)
    }
    
    @IBAction func tapVerifyButton(_ sender: Any) {
        stopDownTimer()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.completeWrapper.alpha = 1.0
            self.verifyButton.alpha = 0.0
            self.completeButton.alpha = 1.0
        }) { (finished) in
        }
    }
    
    @IBAction func tapCompleteButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowPaymentVC", sender: nil)
    }
}
