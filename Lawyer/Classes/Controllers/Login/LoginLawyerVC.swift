//
//  LoginLawyerVC.swift
//  Lawyer
//
//  Created by Admin on 1/15/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class LoginLawyerVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emailField: LoginInfoField!
    @IBOutlet weak var passwordField: LoginInfoField!
    @IBOutlet weak var lgoinButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginUserButton: UIButton!
    
    var userInfo: [String: String]?

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

        
    // MARK: - Main functions
    
    func initUI() {
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.emailField.initInfoField(fieldName: "Email", placeholder: "EMAIL", imageName: "ic_field_email")
        self.passwordField.initInfoField(fieldName: "Password", placeholder: "PASSWORD", imageName: "ic_field_password")

        if self.userInfo != nil, self.emailField != nil, self.passwordField != nil {
            self.emailField.infoField.text = self.userInfo![G.email]
            self.passwordField.infoField.text = self.userInfo![G.password]
        }
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
    
    @IBAction func tapSocialFBButton(_ sender: UIButton) {
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            print(cookie.name + "=" + cookie.value)

            guard let domainRange: Range = cookie.domain.range(of: "facebook") else {
                continue
            }
            
            if (!domainRange.isEmpty) {
                storage.deleteCookie(cookie)
            }
        }
        
        let loginButton = FBLoginButton()
        loginButton.permissions = ["email"]
        
        fbOpenSession()
    }
    
    @IBAction func tapSocialGoogleButton(_ sender: UIButton) {
        signintoGoogle()
    }
    
    @IBAction func tapSocialTwitterButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tapForgotPasswordButton(_ sender: UIButton) {
        forgotPassword()
    }
    
    @IBAction func tapSkipButton(_ sender: UIButton) {
        AppShared.clearUserCridentials()
        self.performSegue(withIdentifier: "SkipToMain", sender: nil)
    }
    
    @IBAction func tapLoginButton(_ sender: UIButton) {
        view.window?.endEditing(true)
        
        guard let email = emailField.infoField.text, !email.isEmpty else {
            emailField.infoField.becomeFirstResponder()
            return
        }
        
        guard let password = passwordField.infoField.text, !password.isEmpty else {
            passwordField.infoField.becomeFirstResponder()
            return
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let latitude = "\(appDelegate.userLocation!.coordinate.latitude)"   // "40.123456"
        let longitude = "\(appDelegate.userLocation!.coordinate.longitude)" // "-127.123456"
        
        SVProgressHUD.show()
        AppWebClient.LoginLawyer(email: email, password: password, latitude: latitude, longitude: longitude) { (json) in
            
            guard let response = json else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "Failed to call LoginLawyer api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let token = response[G.response].string else {
                SVProgressHUD.dismiss()
                return
            }
            
            guard let qbLogin = response[G.qb_login].string, var qbPassword = response[G.qb_password].string, var qbFullname = response[G.qb_fullname].string else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "No QuickBlox info in LoginLawyer api.")
                return;
            }
            
            AppShared.saveUserCridentials(email: email,
                                          password: password,
                                          tokenString: token,
                                          loginType: G.lawyer,
                                          qbLogin: qbLogin,
                                          qbPassword: qbPassword,
                                          qbFullname: qbFullname)
            
            AppShared.updateLawyerStatus(liveStatus: G.Online)
            
//            self.performSegue(withIdentifier: "SignedInAsLawyer", sender: nil)
            
            
            // login to QuickBlox
            AppManager.shared.loginToQB(qbLogin: qbLogin, qbPassword: qbPassword, qbFullname: qbFullname) { (user, error) in
                if let error = error {
                    self.finishToLoginQB(success: false, error: error.localizedDescription)
                }
                else {
                    AppManager.shared.connectToChat(user: user!) { (error) in
                        self.finishToLoginQB(success: true)
                    }
                }
            }
        }
    }
    
    @IBAction func tapLoginUserButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToLoginLawyerVC(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        if (unwindSegue.identifier == "SignedUpAsLawyer") {
            if self.userInfo != nil, self.emailField != nil, self.passwordField != nil {
                self.emailField.infoField.text = self.userInfo![G.email]
                self.passwordField.infoField.text = self.userInfo![G.password]
            }
        }
    }
    
    func fbOpenSession() {
        let permissions = ["public_profile", "email", "user_friends"]
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: permissions, from: self.view.window?.rootViewController) { (result, error) in
            if (error != nil) {
                print("error = \(error!.localizedDescription)")
            }
            else if (result!.isCancelled) {
                print("FB login cancelled")
            }
            else {
                if (result!.grantedPermissions.contains("email")) {
                    let parameters = ["fields": "picture, email,name,first_name,last_name"]
                    GraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
                        if (error == nil) {
                            guard let user = result as? [String: Any] else {
                                return
                            }
                            
                            let userId = user["id"] as! String
                            let fullName = user["name"] as! String
                            let lastName = user["last_name"]
                            let email = user["email"] as! String
                            let profileURL = "http://graph.facebook.com/\(userId)/picture?width=9999"
                            
                            print("==============================\nuserId = \(userId)\nfullName = \(fullName)\nlastName = \(lastName!)\nemail = \(email)\nprofileURL = \(profileURL)")
                            
                            self.socialLawyerLogin(fullName: fullName, email: email, socialType: G.facebook, fbUserId: userId, googleUserId: "", twitterUserId: "")
                        }
                    }
                }
                else {
                    
                }
            }
        }
    }
    
    func signintoGoogle() {
    }
    
    func finishToLoginQB(success: Bool, error: String? = nil) {
        SVProgressHUD.dismiss()
        
        if (success) {
            self.performSegue(withIdentifier: "SignedInAsLawyer", sender: nil)
        }
        else {
            self.showAlert(title: nil, msg: error)
        }
    }

    func forgotPassword() {
        view.window?.endEditing(true)
        
        guard let email = emailField.infoField.text, !email.isEmpty else {
            emailField.infoField.becomeFirstResponder()
            return
        }
        
        SVProgressHUD.show()
        AppWebClient.ForgotPasswordLawyer(email: email) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call ForgotPasswordLawyer api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let message = response[G.response].string else {
                return
            }
            
            self.showAlert(msg: message)
        }
    }
    
    func signout() {
        print("signout")
        
        AppShared.clearUserCridentials()
    }
    
    
    // MARK: - API functions
    
    func apiTestFunc() {
        SVProgressHUD.show()
        
//        AppWebClient.GetNotification { (json) in
//        AppWebClient.GetCharges { (json) in
//        AppWebClient.ForgotPasswordUser(email: "user1@mail.com") { (json) in
        AppWebClient.GetAvailableTime(date: "2019-12-25", lawyerId: "22") { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to test api.")
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
            
        }
    }
    
    func socialLawyerLogin(fullName: String, email: String, socialType: String, fbUserId: String, googleUserId: String, twitterUserId: String) {
        SVProgressHUD.show()
        
        AppWebClient.SocialLawyerLogin(fullName: fullName, email: email, loginType: socialType, fbUserId: fbUserId, googleUserId: googleUserId, twitterUserId: twitterUserId) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call SocialLawyerLogin api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let token = response[G.response].string else {
                return
            }
            
            guard let qbLogin = response[G.qb_login].string, let qbPassword = response[G.qb_password].string, let qbFullname = response[G.qb_fullname].string else {
                self.showAlert(msg: "No QuickBlox info in SocialLawyerLogin api")
                return
            }
            
            AppShared.saveUserCridentials(email: email, password: "", tokenString: token, loginType: G.lawyer, qbLogin: qbLogin, qbPassword: qbPassword, qbFullname: qbFullname)
            
            AppShared.updateLawyerStatus(liveStatus: G.Online)
            
            // login to QuickBlox
            AppManager.shared.loginToQB(qbLogin: qbLogin, qbPassword: qbPassword, qbFullname: qbFullname) { (user, error) in
                if let error = error {
                    self.finishToLoginQB(success: false, error: error.localizedDescription)
                }
                else {
                    AppManager.shared.connectToChat(user: user!) { (error) in
                        self.finishToLoginQB(success: true)
                    }
                }
            }
        }
    }
}


extension LoginLawyerVC: UITextFieldDelegate {
    
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
