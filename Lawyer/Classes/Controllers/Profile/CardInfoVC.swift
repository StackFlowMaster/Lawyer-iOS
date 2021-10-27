//
//  CardInfoVC.swift
//  Lawyer
//
//  Created by Admin on 11/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class CardInfoVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var addMyCardButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    @IBOutlet weak var completeWrapper: UIView!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
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
        self.title = "Card information"
        
        addMyCardButton.shadow()
        goBackButton.shadow()
        goBackButton.alpha = 0.0
    }
    
    func updateWrapper() {
        let scrollViewHeight = self.scrollView.frame.height
        let wrapperHeight = self.view.frame.width * 668.0 / 375.0
        if (wrapperHeight > scrollViewHeight) {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: wrapperHeight)
        }
    }
    
    @IBAction func tapScanCameraButton(_ sender: Any) {
        
    }
    
    @IBAction func tapAddMyCardButton(_ sender: Any) {
        guard let cardNumber = self.cardNumberField.text, !cardNumber.isEmpty,
            let expiry = self.expiryField.text, !expiry.isEmpty,
            let cvv = self.cvvField.text, !cvv.isEmpty else {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.completeWrapper.alpha = 1.0
            self.addMyCardButton.alpha = 0.0
            self.goBackButton.alpha = 1.0
        }) { (finished) in
        }
    }
    
    @IBAction func tapGoBackButton(_ sender: Any) {
        if (AppShared.getAccountType() == .Guest) {
            self.performSegue(withIdentifier: "AddedCardInfoToGuest", sender: nil)
            return
        }
        
        self.performSegue(withIdentifier: "AddedCardInfo", sender: nil)
    }
}
