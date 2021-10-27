//
//  SignupVC.swift
//  Lawyer
//
//  Created by Admin on 10/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class SignupVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: LoginInfoField!
    @IBOutlet weak var emailField: LoginInfoField!
    @IBOutlet weak var passwordField: LoginInfoField!
    @IBOutlet weak var confirmField: LoginInfoField!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var registerLawyerButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        
        if (segue.identifier == "SignedUpAsUser") {
            let vc = segue.destination as! LoginVC
            vc.userInfo = sender as? [String : String]
        }
    }
    
    func initUI() {
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.nameField.initInfoField(fieldName: "Full Name", placeholder: "FULLNAME", imageName: "ic_field_name")
        self.emailField.initInfoField(fieldName: "Email", placeholder: "EMAIL", imageName: "ic_field_email")
        self.passwordField.initInfoField(fieldName: "Password", placeholder: "PASSWORD", imageName: "ic_field_password")
        self.confirmField.initInfoField(fieldName: "Confirm Password", placeholder: "CONFIRM PASSWORD", imageName: "ic_field_password")
        
    }
    
    func updateWrapper() {
        let scrollViewHeight = self.scrollView.frame.height
        let wrapperHeight = self.view.frame.width * 812.0 / 375.0
        if (wrapperHeight > scrollViewHeight) {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: wrapperHeight)
        }
    }
    
    func setHighlightInfoField(textField: UITextField, highlight: Bool) {
        let superView = textField.superview
        if (superView != nil && superView is LoginInfoField) {
            (superView as! LoginInfoField).highlightInfoField(highlight: highlight, animated: true)
        }
    }
    
    @IBAction func tapSugnupButton(_ sender: UIButton) {
        view.window?.endEditing(true)
        
        guard let fullname = nameField.infoField.text,
            fullname.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 else {
            self.showAlert(msg: "Please enter full name") { (action) in
                self.nameField.infoField.becomeFirstResponder()
            }
            return
        }
        
        guard let email = emailField.infoField.text,
        email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 else {
            self.showAlert(msg: "Please enter email") { (action) in
                self.emailField.infoField.becomeFirstResponder()
            }
            return
        }
        
        if (!AppShared.isValidEmail(emailStr: email)) {
            self.showAlert(msg: "Please enter a valid email address") { (action) in
                self.emailField.infoField.becomeFirstResponder()
            }
            return
        }
        
        guard let password = passwordField.infoField.text, !password.isEmpty, password.count > 7 else {
            self.showAlert(msg: "Please enter at least 8 characters") { (action) in
                self.passwordField.infoField.becomeFirstResponder()
            }
            return
        }
        
        guard let confirm = confirmField.infoField.text, !confirm.isEmpty, confirm.count > 7 else {
            self.showAlert(msg: "Please enter at least 8 characters") { (action) in
                self.confirmField.infoField.becomeFirstResponder()
            }
            return
        }
        
        if (password != confirm) {
            self.showAlert(msg: "Password does not patch") { (action) in
                self.confirmField.infoField.becomeFirstResponder()
            }
            return
        }

        let params = [G.full_name: fullname,
                      G.email: email,
                      G.password: password,
                      G.confirm_password: confirm,
                      G.city: "city",
                      G.state: "state",
                      G.country: "country",
                      G.mobile_number: "1234567890"]
        
        SVProgressHUD.show()
        AppWebClient.RegisterUser(params: params) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call RegisterUser api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
//            guard let user = Mapper<User>().map(JSONString: response["User"].rawString()!) else {
//                return
//            }
            
//            user.userDidLogin()
            
            let message = response[G.response].string
            self.showAlert(msg: message!) { (action) in
                let userInfo = [G.full_name: fullname, G.email: email, G.password: password]
                self.performSegue(withIdentifier: "SignedUpAsUser", sender: userInfo)
            }
        }
    }
}


extension SignupVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.setHighlightInfoField(textField: textField, highlight: true)
        return true
    }
    
    @available(iOS 2.0, *)
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.setHighlightInfoField(textField: textField, highlight: false)
        return true
    }
}
