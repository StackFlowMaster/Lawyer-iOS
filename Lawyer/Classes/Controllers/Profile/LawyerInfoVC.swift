//
//  LawyerInfoVC.swift
//  Lawyer
//
//  Created by Admin on 11/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class LawyerInfoVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    
    @IBOutlet weak var infoWrapper: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var bankNameField: UITextField!
    @IBOutlet weak var accountNumberField: UITextField!
    @IBOutlet weak var accountTypeField: UITextField!
    @IBOutlet weak var branchField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var goBackButton: UIButton!
    
    @IBOutlet weak var completeWrapper: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        (self.tabBarController as! LawyerTabVC).showTabView(show: false)
        AppManager.shared.mainTabVC.showTabView(show: false)
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
        self.navigationController?.clear()
        
        confirmButton.shadow()
        goBackButton.shadow()
        completeWrapper.alpha = 0.0
    }
    
    func updateWrapper() {
        let scrollViewHeight = self.scrollView.frame.height
        let wrapperHeight = self.view.frame.width * 732.0 / 375.0
        if (wrapperHeight > scrollViewHeight) {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: wrapperHeight)
        }
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapConfirmButton(_ sender: Any) {
        guard let name = self.nameField.text, !name.isEmpty,
            let bankName = self.bankNameField.text, !bankName.isEmpty,
            let accountNumber = self.accountNumberField.text, !accountNumber.isEmpty,
            let accountType = self.accountTypeField.text, !accountType.isEmpty,
            let branch = self.branchField.text, !branch.isEmpty,
            let amount = self.amountField.text, !amount.isEmpty else {
                return
        }
        
        view.window?.endEditing(true)
        
        SVProgressHUD.show()
        AppWebClient.CashOut(fullName: name, bankName: bankName, accountNumber: accountNumber, accountType: accountType, branch: branch, amount: amount) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call CashOut api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            if let responseString = response[G.response].string {
                self.showAlert(msg: responseString)
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.infoWrapper.alpha = 0.0
                    self.completeWrapper.alpha = 1.0
                }) { (finished) in
                }
            }
        }
    }
    
    @IBAction func tapGoBackButton(_ sender: Any) {
        self.performSegue(withIdentifier: "UpdatedLawyerInfo", sender: nil)
    }
}
