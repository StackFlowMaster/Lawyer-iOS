//
//  SignupLawyerVC.swift
//  Lawyer
//
//  Created by Admin on 10/30/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class SignupLawyerVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: LoginInfoField!
    @IBOutlet weak var emailField: LoginInfoField!
    @IBOutlet weak var passwordField: LoginInfoField!
    @IBOutlet weak var confirmField: LoginInfoField!
    @IBOutlet weak var degreeField: LoginInfoField!
    @IBOutlet weak var browseField: LoginInfoField!
    @IBOutlet weak var typeField: LoginInfoField!
    @IBOutlet weak var timeField: LoginInfoField!
    @IBOutlet weak var timeWrapperToolBar: UIToolbar!
    @IBOutlet weak var timeWrapper: UIView!
    @IBOutlet weak var timeWrapperBottom: NSLayoutConstraint!
//    @IBOutlet weak var fromTimePicker: UIDatePicker!
//    @IBOutlet weak var toTimePicker: UIDatePicker!
    @IBOutlet weak var fromTimeTableView: UITableView!
    @IBOutlet weak var toTimeTableView: UITableView!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    
    var lawyerType: LawyerType?
    
    var picker = UIImagePickerController();
    
    var images = [UIImage]()
    
    var fromTime: Int = 0
    var toTime: Int = 0
    
    var selectedFromTime: Int = 0
    var selectedToTime: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        clearNavigationStacks()
        
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
        
        if (segue.identifier == "SignedUpAsLawyer") {
            let vc = segue.destination as! LoginLawyerVC
            vc.userInfo = sender as? [String : String]
        }
        else if (segue.identifier == "ShowLawyerTypes") {
            let vc = segue.destination as! LawyerTypesVC
            vc.unwindSegueIdentifier = "UnwindToLawyerSignupVCWithType"
        }
    }
    
    // MARK: - Main functions
    
    func clearNavigationStacks() {
        var existLoginVC = false
        
        var viewControllers = self.navigationController!.viewControllers
        if (viewControllers.count < 1) {
            return
        }
        
        for i in 0 ..< viewControllers.count {
            let vc = viewControllers[i];
            if vc is LoginLawyerVC {
                existLoginVC = true
                continue;
            }
        }
        
        if (!existLoginVC) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "LoginLawyerVC") as! LoginLawyerVC
            viewControllers.insert(vc, at: 1)
        }
        
        self.navigationController!.viewControllers = viewControllers
    }
    
    func initUI() {
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        self.degreeField.infoField.isSecureTextEntry = false
        self.browseField.infoField.isSecureTextEntry = false
        self.typeField.infoField.isSecureTextEntry = false
        self.timeField.infoField.isSecureTextEntry = false
        
        self.nameField.initInfoField(fieldName: "Full Name", placeholder: "FULLNAME", imageName: "ic_field_name")
        self.emailField.initInfoField(fieldName: "Email", placeholder: "EMAIL", imageName: "ic_field_email")
        self.passwordField.initInfoField(fieldName: "Password", placeholder: "PASSWORD", imageName: "ic_field_password")
        self.confirmField.initInfoField(fieldName: "Confirm", placeholder: "CONFIRM", imageName: "ic_field_password")
        self.degreeField.initInfoField(fieldName: "Degree", placeholder: "DEGREE", imageName: "ic_field_degree")
        self.browseField.initInfoField(fieldName: "Browse", placeholder: "BROWSE", imageName: "ic_field_browse")
        self.typeField.initInfoField(fieldName: "Lawyer Type", placeholder: "LAWYER TYPE", imageName: "ic_field_name")
        self.timeField.initInfoField(fieldName: "Time", placeholder: "TIME", imageName: "ic_field_clock")
        
//        self.timeField.infoField.inputAccessoryView = self.timeWrapperToolBar
//        self.timeField.infoField.inputView = self.timeWrapper
        
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
    
    func showFilePicker() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: .default) {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
//        alert.dismiss(animated: true, completion: nil)
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                UIAlertAction in
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
//        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        images.append(image)
    }
    
    @IBAction func tapSugnupButton(_ sender: UIButton) {
        view.window?.endEditing(true)
        
        signupAsLawyer()
    }
    
    func showTypesVC() {
        self.performSegue(withIdentifier: "ShowLawyerTypes", sender: nil)
    }
    
    @IBAction func unwindToLawyerSignupVCWithType(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
        
        if (unwindSegue.identifier == "UnwindToLawyerSignupVCWithType") {
            let typesVC = unwindSegue.source as! LawyerTypesVC
            let type = typesVC.selectedLawyerType
            if (type != nil) {
                self.typeField.infoField.text = type?.type
            }
        }
    }
    
    func showTimePicker(show: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.timeWrapperBottom.constant = show ? 0.0 : -300.0
            self.view.layoutIfNeeded()
        }) { (finished) in
            
        }
    }
    
    @IBAction func tapTimeCancelButton(_ sender: UIBarButtonItem) {
//        self.timeField.infoField.resignFirstResponder()
        showTimePicker(show: false)
    }
    
    @IBAction func tapTimeDoneButton(_ sender: UIBarButtonItem) {
//        let fromTime = getTime(date: fromTimePicker.date)
//        let toTime = getTime(date: toTimePicker.date)
        
        fromTime = selectedFromTime
        toTime = selectedToTime
        
        self.timeField.infoField.text = "\(fromTime):00 - \(toTime):00"
        
//        self.timeField.infoField.resignFirstResponder()
        showTimePicker(show: false)
    }
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let strTime = formatter.string(from: date)
        return strTime
    }
    
    // MARK: - API functions
    
    func saveImage() {
        guard images.count > 0 else {
            return
        }

        let image = images[0]
        
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = "image.png"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.pngData(),
          !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    // test
    
    func signupAsLawyer() {
        
        guard let fullname = nameField.infoField.text, !fullname.isEmpty,
            fullname.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 else {
            self.showAlert(msg: "Please enter full name") { (action) in
                self.nameField.infoField.becomeFirstResponder()
            }
            return
        }
        
        guard let email = emailField.infoField.text, !email.isEmpty,
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

        let degree = degreeField.infoField.text
        let type = typeField.infoField.text
        
        guard let time = timeField.infoField.text, !time.isEmpty else {
            return
        }
        let times = time.components(separatedBy: " - ")
        let fromTime = times[0]
        let toTime = times[1]

        let params = [G.full_name: fullname,
                      G.email: email,
                      G.password: password,
                      G.confirm_password: confirm,
                      G.degree: degree!,
                      G.type: type!,
                      G.available_from: fromTime,
                      G.available_to: toTime]
        
        var files = [LawyerzFile]()
        for i in 0 ..< images.count {
            let file = LawyerzFile(name: "file_\(i).png", key: "\(G.certificates)[\(i)]", data: images[i].pngData()!)
            files.append(file)
        }
        
        /*
        AppWebClient.RegisterLawyer(params: params) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to register as Lawyer.")
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
                self.performSegue(withIdentifier: "SignedUpAsLawyer", sender: userInfo)
            }
            
        }
        */
    }
    
    // MARK: -
}


extension SignupLawyerVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == self.browseField.infoField) {
            view.window?.endEditing(true)
            self.showFilePicker()
            return false
        }
        else if (textField == self.typeField.infoField) {
            view.window?.endEditing(true)
            self.showTypesVC()
            return false
        }
        else if (textField == self.timeField.infoField) {
            view.window?.endEditing(true)
            self.showTimePicker(show: true)
            return false
        }
        
        self.setHighlightInfoField(textField: textField, highlight: true)
        return true
    }
    
    @available(iOS 2.0, *)
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.setHighlightInfoField(textField: textField, highlight: false)
        return true
    }
}


extension SignupLawyerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if (tableView == fromTimeTableView) {
            cell = tableView.dequeueReusableCell(withIdentifier: "FromTimeCell", for: indexPath)
        }
        else if (tableView == toTimeTableView) {
            cell = tableView.dequeueReusableCell(withIdentifier: "ToTimeCell", for: indexPath)
            if (indexPath.row > selectedFromTime) {
                cell?.textLabel?.textColor = UIColor.darkText
                cell?.selectionStyle = .default
            }
            else {
                cell?.textLabel?.textColor = UIColor.darkGray
                cell?.selectionStyle = .none
            }
        }
        
        cell!.textLabel!.text = "\(indexPath.row):00"
        
        return cell!
    }
}


extension SignupLawyerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == fromTimeTableView) {
            selectedFromTime = indexPath.row
            toTimeTableView.reloadData()
        }
        else if (tableView == toTimeTableView) {
            selectedToTime = indexPath.row
        }
    }
}
