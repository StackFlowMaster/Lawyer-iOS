//
//  LoginVC.swift
//  Lawyer
//
//  Created by Admin on 10/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class LoginVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emailField: LoginInfoField!
    @IBOutlet weak var passwordField: LoginInfoField!
    @IBOutlet weak var lgoinButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginLawyerButton: UIButton!
    
    var userInfo: [String: String]?
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        startLocationManager()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let navBarFrame = self.navigationController?.navigationBar.frame
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.topBarHeight = -navBarFrame!.origin.y
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

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let location = appDelegate.userLocation else {
            showAlert(msg: "Can't get user location")
            return
        }
        let latitude = "\(location.coordinate.latitude)"   // "40.123456"
        let longitude = "\(location.coordinate.longitude)" // "-127.123456"
        
        SVProgressHUD.show()
        AppWebClient.LoginUser(email: email, password: password, latitude: latitude, longitude: longitude) { (json) in
            
            guard let response = json else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "Failed to call Login api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let token = response[G.response].string else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "Invalid token")
                return
            }
            
            guard let qbLogin = response[G.qb_login].string, let qbPassword = response[G.qb_password].string, let qbFullname = response[G.qb_fullname].string else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "No QuickBlox info in Login api.")
                return;
            }
            
            // stop location manager
            self.stopLocationManager()
            
            AppShared.saveUserCridentials(email: email,
                                          password: password,
                                          tokenString: token,
                                          loginType: G.user,
                                          qbLogin: qbLogin,
                                          qbPassword: qbPassword,
                                          qbFullname: qbFullname)
            
            self.updateUserStatus(liveStatus: G.Online)
            
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
    
    @IBAction func tapLoginLawyerButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ShowLoginLawyer", sender: nil)
    }
    
    @IBAction func unwindToLoginVC(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        if (unwindSegue.identifier == "signout") {
            signout()
        }
        else if (unwindSegue.identifier == "SignedUpAsUser") {
            if (self.userInfo != nil) {
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
                            
                            self.socialUserLogin(fullName: fullName, email: email, socialType: G.facebook, fbUserId: userId, googleUserId: "", twitterUserId: "")
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
    
    
    /*
    func loginToQB(login: String, password: String, fullname: String) {
        QBRequest.logIn(withUserLogin: login, password: password, successBlock: { [weak self] response, user in
            guard let self = self else {
                return
            }
            
            user.password = password
            Profile.synchronize(user)
            
            if user.fullName != fullname {
                self.updateFullName(fullName: fullName, login: login)
            }
            else {l
            }
        }, errorBlock: { [weak self] response in
            if response.status == QBResponseStatusCode.unAuthorized {
                Profile.clearProfile()
            }
            self!.finishToLoginQB(success: false, error: response.error?.error?.localizedDescription)
        })
    }
    
    func updateFullName(fullName: String, login: String) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: {  [weak self] response, user in
            Profile.update(user)
            self!.finishToLoginQB(success: true)
        }, errorBlock: { [weak self] respone in
            self!.finishToLoginQB(success: true)
        })
    }
    
    func connectToChat(user: QBUUser) {
        QBChat.instance.connect(withUserID: user.id,
                                password: LoginConstant.defaultPassword,
                                completion: { [weak self] error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            // Clean profile
                                            Profile.clearProfile()
                                        }
                                    }
                                    else {
                                        AppShared.registerForRemoteNotifications()
                                    }
        })
    }
    */
    
    func finishToLoginQB(success: Bool, error: String? = nil) {
        SVProgressHUD.dismiss()
        
        if (success) {
            self.performSegue(withIdentifier: "SignedInAsUser", sender: nil)
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
        AppWebClient.ForgotPasswordUser(email: email) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call ForgotPasswordUser api.")
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

        let accountType = AppShared.getAccountType()
        if (accountType == .Lawyer) {
//            AppShared.updateLawyerStatus(liveStatus: G.Offline, showLoading: true)

            SVProgressHUD.show()
            AppWebClient.UpdateLawyerStatus(liveStatus: G.Offline) { (json) in
                
                guard let response = json else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: "Failed to call UpdateLawyerStatus api.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: response[G.error].string)
                    return;
                }
                
                AppManager.shared.signout { (error) in
                    SVProgressHUD.dismiss()
//                    if let error = error {
//                        self.showAlert(msg: error)
//                    }
                }
            }
        }
        else if (accountType == .User) {
            SVProgressHUD.show()
            AppWebClient.UpdateUserStatus(liveStatus: G.Offline) { (json) in
                guard let response = json else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: "Failed to call UpdateUserStatus api.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: response[G.error].string)
                    return;
                }
                
                AppManager.shared.signout { (error) in
                    SVProgressHUD.dismiss()
//                    if let error = error {
//                        self.showAlert(msg: error)
//                    }
                }
            }
        }
        
        AppShared.clearUserCridentials()
    }
    
    func startLocationManager() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone //kCLDistanceFilterNone// kDistanceFilter
//            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
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
                self.showAlert(msg: "Failed to call test api.")
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
    
    func updateUserStatus(liveStatus: String, showLoading: Bool = false) {
        if (showLoading) {
            SVProgressHUD.show()
        }
        
        AppWebClient.UpdateUserStatus(liveStatus: liveStatus) { (json) in
            if (showLoading) {
                SVProgressHUD.dismiss()
            }
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call UpdateUserStatus api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
        }
    }
    
    func socialUserLogin(fullName: String, email: String, socialType: String, fbUserId: String, googleUserId: String, twitterUserId: String) {
        SVProgressHUD.show()
        
        AppWebClient.SocialUserLogin(fullName: fullName, email: email, loginType: socialType, fbUserId: fbUserId, googleUserId: googleUserId, twitterUserId: twitterUserId) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call SocialUserLogin api.")
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
                self.showAlert(msg: "No QuickBlox info in SocialUserLogin api")
                return
            }
            
            AppShared.saveUserCridentials(email: email,
                                          password: "",
                                          tokenString: token,
                                          loginType: G.user,
                                          qbLogin: qbLogin,
                                          qbPassword: qbPassword,
                                          qbFullname: qbFullname)
            
            self.updateUserStatus(liveStatus: G.Online)
            
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


extension LoginVC: UITextFieldDelegate {
    
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


extension LoginVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation: CLLocation = locations.last!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if (appDelegate.userLocation != nil && newLocation == appDelegate.userLocation) {
            return;
        }
        
        appDelegate.userLocation = newLocation
        print("=====> User Location : (\(appDelegate.userLocation!.coordinate.latitude), \(appDelegate.userLocation!.coordinate.longitude))")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("=====> User Location Failed : \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        #if DEBUG
            var strStatus = "NotDetermined"
            switch (status) {
                case .notDetermined:
                    strStatus = "NotDetermined"
                    break;
                case .restricted:
                    strStatus = "Restricted"
                    break;
                case .denied:
                    strStatus = "Denied"
                    break;
                case .authorizedAlways:
                    strStatus = "AuthorizedAlways"
                    break;
                case .authorizedWhenInUse:
                    strStatus = "AuthorizedWhenInUse"
                    break;
                    
                default:
                    break;
                
            }
            print("=====> User didChangeAuthorizationStatus : \(status) (\(strStatus))")
        #endif
    }
}
