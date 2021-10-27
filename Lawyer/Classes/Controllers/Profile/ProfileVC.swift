//
//  ProfileVC.swift
//  Lawyer
//
//  Created by Admin on 11/1/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Cosmos
import CoreLocation

private let ITEM_COUNT = 12

class ProfileVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var wrapperHeight: NSLayoutConstraint!
    
    
    // MARK: - User profile
    @IBOutlet weak var profileWrapper: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var buttonWrapper: UIView!
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var appointmentsButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    
    // MARK: - Lawyer profile
    @IBOutlet weak var lawyerProfileWrapper: UIView!
    @IBOutlet weak var lawyerProfileImageView: UIImageView!
    @IBOutlet weak var lawyerStatusImageView: UIImageView!
    @IBOutlet weak var lawyerStatusButton: UIButton!
    @IBOutlet weak var lawyerNameLabel: UILabel!
    @IBOutlet weak var lawyerTypeLabel: UILabel!
    @IBOutlet weak var lawyerRatingView: CosmosView!
    
    @IBOutlet weak var lawyerStatusOptionWrapper: UIView!
    @IBOutlet weak var lawyerStatusOptionActive: UIButton!
    @IBOutlet weak var lawyerStatusOptionOffline: UIButton!
    @IBOutlet weak var lawyerStatusOptionInvisible: UIButton!
    
    @IBOutlet weak var lawyerReviewWrapper: UIView!
    @IBOutlet weak var lawyerCommentsLabel: UILabel!
    @IBOutlet weak var lawyerConsultsLabel: UILabel!
    @IBOutlet weak var lawyerViewsLabel: UILabel!
    
    @IBOutlet weak var lawyerInfoWalletButton: UIButton!
    @IBOutlet weak var lawyerInfoCashoutButton: UIButton!
    @IBOutlet weak var lawyerInfoTimeButton: UIButton!
    
    @IBOutlet weak var lawyerInfoWalletLabel: UILabel!
    @IBOutlet weak var lawyerInfoCashoutLabel: UILabel!
    @IBOutlet weak var lawyerInfoTimeLabel: UILabel!
    
    @IBOutlet weak var lawyerDescLabel: UILabel!
    
    @IBOutlet weak var lawyerGraphWrapper: UIView!
    @IBOutlet weak var lawyerGraphView: CombinedChartView!
    
    
    @IBOutlet weak var timeWrapperToolBar: UIToolbar!
    @IBOutlet weak var timeWrapper: UIView!
    @IBOutlet weak var timeWrapperBottom: NSLayoutConstraint!
    @IBOutlet weak var fromTimePicker: UIDatePicker!
    @IBOutlet weak var toTimePicker: UIDatePicker!
    
    var lawyerStatus: G.UserStatus = .Active {
        didSet {
            var image: UIImage?
            switch lawyerStatus {
            case .Active:
                image = UIImage(named: "ic_status_active")
            case .Offline:
                image = UIImage(named: "ic_status_offline")
            case .Invisible:
                image = UIImage(named: "ic_status_invisible")
            }
            self.lawyerStatusImageView.image = image!
        }
    }
    
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    var monthValues = [Int]()
    
    var fromDate: Date = Date()
    var toDate: Date = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        (self.tabBarController as! LawyerTabVC).showTabView(show: true)
        AppManager.shared.mainTabVC.showTabView(show: true)
        
        getProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrapper()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ShowLocationVC") {
            let vc: LocationVC = segue.destination as! LocationVC
            vc.location = sender as? CLLocation
        }
    }
    
    
    // MARK: - UI functions
    
    func initUI() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.clear()
        
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        let accountType: G.AccountType = AppShared.getAccountType()
        if (accountType == .Lawyer) {
            self.lawyerProfileWrapper.isHidden = false
            initLawyerProfileUI()
        }
        else {
            self.lawyerProfileWrapper.isHidden = true
            initUserProfileUI()
        }
    }
    
    func initUserProfileUI() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2.0
        
        self.ratingView.isUserInteractionEnabled = false
        self.ratingView.alpha = 0.0
        
        let messageCount = ChatManager.instance.storage.unreadMessageCount
        self.messagesButton.setTitle("\(messageCount) Unread Messages", for: .normal)
        self.messagesButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        self.messagesButton.titleLabel?.textAlignment = .center
        
        //applying the line break mode
        self.appointmentsButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        self.appointmentsButton.titleLabel?.textAlignment = .center
        let buttonText: NSString = "Coming up\n12:30am"
        
        let newlineRange: NSRange = buttonText.range(of: "\n")
        var substring1 = ""
        var substring2 = ""
        if (newlineRange.location != NSNotFound) {
            substring1 = buttonText.substring(to: newlineRange.location)
            substring2 = buttonText.substring(from: newlineRange.location)
        }
        
        //assigning diffrent fonts to both substrings
        let font1: UIFont = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        let attributes1 = [NSMutableAttributedString.Key.font: font1]
        let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes1)
        
        let font2: UIFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let attributes2 = [NSMutableAttributedString.Key.font: font2]
        let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes2)
        
        //appending both attributed strings
        attrString1.append(attrString2)
        
        //assigning the resultant attributed strings to the button
        appointmentsButton.setAttributedTitle(attrString1, for: .normal)
    }
    
    func initLawyerProfileUI() {
        self.lawyerProfileImageView.layer.cornerRadius = self.lawyerProfileImageView.frame.width / 2.0
        
        self.lawyerStatusImageView.layer.borderWidth = 2.0
        self.lawyerStatusImageView.layer.borderColor = UIColor.white.cgColor
        self.lawyerStatusImageView.layer.cornerRadius = self.lawyerStatusImageView.frame.height / 2
        
        self.lawyerRatingView.isUserInteractionEnabled = false
        self.lawyerRatingView.alpha = 0.0
    }
    
    func updateWrapper() {
        let scrollViewHeight = self.scrollView.frame.height
        
        let accountType: G.AccountType = AppShared.getAccountType()
        if (accountType == .Lawyer) {
            let height = self.view.frame.width * 355.0 / 375.0 + lawyerGraphWrapper.frame.maxY + 20
            wrapperHeight.constant = height > scrollViewHeight ? height : scrollViewHeight
        }
        else {
            let height = self.view.frame.width * 732.0 / 375.0
            wrapperHeight.constant = height > scrollViewHeight ? height : scrollViewHeight
        }
        view.layoutIfNeeded()

        scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: wrapperHeight.constant)
        
        var radius = profileImageView.frame.height / 2.0
        profileImageView.setRoundBorderEdgeView(cornerRadius: radius, borderWidth: 2.0, borderColor: .white)
        radius = lawyerProfileImageView.frame.height / 2.0
        lawyerProfileImageView.setRoundBorderEdgeView(cornerRadius: radius, borderWidth: 2.0, borderColor: .white)
    }
    
    @IBAction func tapInfoButton(_ sender: UIButton) {
        if (sender == messagesButton) {
            let mainTabVC = AppManager.shared.mainTabVC
            mainTabVC.tapTabButton(mainTabVC.tabButtonMessages)
        }
        else if (sender == appointmentsButton) {
            
        }
        else if (sender == locationButton) {
            self.performSegue(withIdentifier: "ShowLocationVC", sender: nil)
        }
    }
    
    @IBAction func tapLawyerStatusButton(_ sender: Any) {
        lawyerStatusOptionActive.isSelected = lawyerStatus == .Active
        lawyerStatusOptionOffline.isSelected = lawyerStatus == .Offline
        lawyerStatusOptionInvisible.isSelected = lawyerStatus == .Invisible
        
        showStatusOptionWrapper(show: true)
    }
    
    @IBAction func tapLawyerStatusOptionButton(_ sender: UIButton) {
        lawyerStatusOptionActive.isSelected = sender == lawyerStatusOptionActive
        lawyerStatusOptionOffline.isSelected = sender == lawyerStatusOptionOffline
        lawyerStatusOptionInvisible.isSelected = sender == lawyerStatusOptionInvisible
        
        lawyerStatus = G.UserStatus(rawValue: sender.tag)!
        
        showStatusOptionWrapper(show: false)
    }
    
    @IBAction func tapLawyerInfoButton(_ sender: UIButton) {
        if (sender == lawyerInfoCashoutButton) {
            self.performSegue(withIdentifier: "ShowLawyerInfoVC", sender: nil)
        }
        else if (sender == lawyerInfoTimeButton) {
            showTimeWrapper(show: true)
        }
    }
    
    @IBAction func tapTimeCancel(_ sender: Any) {
        
        showTimeWrapper(show: false)
    }
    
    @IBAction func tapTimeDone(_ sender: Any) {
        let fromDate = fromTimePicker.date
        let toDate = toTimePicker.date
        
        showTimeWrapper(show: false)
        
        editLawyerAvailTime(fromDate: fromDate, toDate: toDate)
    }
    
    func showTimeWrapper(show: Bool) {
        let mainTabVC = AppManager.shared.mainTabVC
        
        if (show) {
            mainTabVC.showTabView(show: !show)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.timeWrapperBottom.constant = show ? 0.0 : -300.0
            self.view.layoutIfNeeded()
        }) { (finished) in
            if (!show) {
                mainTabVC.showTabView(show: !show)
            }
        }
    }
    
    @IBAction func unwindToProfileVC(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        if (unwindSegue.identifier == "AddedCardInfo") {
        }
    }
    
    func showStatusOptionWrapper(show: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.lawyerStatusOptionWrapper.alpha = show ? 1.0 : 0.0
        }) { (finished) in
            self.lawyerStatusButton.isUserInteractionEnabled = show ? false : true
        }
    }
    
    func refreshUserInfo(userInfo: [String: Any]?) {
        if (userInfo == nil) {
            return
        }
        
        
        if let imageUrl = userInfo![G.profile_pic] as? String, !imageUrl.isEmpty {
            lawyerProfileImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }
        else {
            lawyerProfileImageView.image = UIImage(named: "ic_avatar_1")
        }
        
        
        nameLabel.text = userInfo![G.full_name] as? String
//        ratingView.rating = userInfo![G.avg_rating] as! Double
        
        var address: String = ""
        let city = userInfo![G.city] as? String
        if (city != nil && !city!.isEmpty) {
            address = city!
        }
        let state = userInfo![G.state] as? String
        if (state != nil && !state!.isEmpty) {
            address = address + ", \(state!)"
        }
        let country = userInfo![G.country] as? String
        if (country != nil && !country!.isEmpty) {
            address = address + ", \(country!)"
        }
        addressLabel.text = address
        
        
        let messageCount = ChatManager.instance.storage.unreadMessageCount
        self.messagesButton.setTitle("\(messageCount) Unread Messages", for: .normal)
        self.messagesButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        self.messagesButton.titleLabel?.textAlignment = .center
        
        
        //applying the line break mode
        self.appointmentsButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        self.appointmentsButton.titleLabel?.textAlignment = .center
        
        let date = userInfo![G.appointment_date] as! String
        let strAppointment = "\(date.replacingOccurrences(of: "2020-", with: "")) \(userInfo![G.time] as! String)"
        let buttonText: NSString = "Coming up\n\(strAppointment)" as NSString
        
        let newlineRange: NSRange = buttonText.range(of: "\n")
        var substring1 = ""
        var substring2 = ""
        if (newlineRange.location != NSNotFound) {
            substring1 = buttonText.substring(to: newlineRange.location)
            substring2 = buttonText.substring(from: newlineRange.location)
        }
        
        //assigning diffrent fonts to both substrings
        let font1: UIFont = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        let attributes1 = [NSMutableAttributedString.Key.font: font1]
        let attrString1 = NSMutableAttributedString(string: substring1, attributes: attributes1)
        
        let font2: UIFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let attributes2 = [NSMutableAttributedString.Key.font: font2]
        let attrString2 = NSMutableAttributedString(string: substring2, attributes: attributes2)
        
        //appending both attributed strings
        attrString1.append(attrString2)
        
        //assigning the resultant attributed strings to the button
        appointmentsButton.setAttributedTitle(attrString1, for: .normal)
    }
    
    func refreshLawyerInfo(lawyerInfo: [String: Any]?) {
        if (lawyerInfo == nil) {
            return
        }

        lawyerProfileImageView.image = nil
        if let imageUrl = lawyerInfo![G.profile_pic] as? String, !imageUrl.isEmpty {
            lawyerProfileImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }
        
        
        lawyerNameLabel.text = lawyerInfo![G.full_name] as? String
        lawyerTypeLabel.text = lawyerInfo![G.type] as? String
//        lawyerRatingView.rating = lawyerInfo![G.avg_rating] as! Double
        
        lawyerCommentsLabel.text = lawyerInfo![G.comments_count] as? String
        lawyerConsultsLabel.text = lawyerInfo![G.consults_count] as? String
        lawyerViewsLabel.text = lawyerInfo![G.view_count] as? String
        
        lawyerDescLabel.text = nil
        
        if let amount = lawyerInfo![G.wallet_amount] {
            lawyerInfoWalletLabel.text = "$ \(amount as! String)"
        }
        else {
            lawyerInfoWalletLabel.text = "$ 0"
        }
        
        lawyerInfoCashoutLabel.text = "Cash out"
        
        if let fromTime = lawyerInfo![G.available_from], let toTime = lawyerInfo![G.available_to] {
            lawyerInfoTimeLabel.text = "Available\n\(fromTime as! String) - \(toTime as! String)"
        }
        else {lawyerInfoTimeLabel.text = "Available time\n"
        }
    }
    

    // MARK: - API functions
    
    func getProfile() {
        
        SVProgressHUD.show()
        
        if (AppShared.getAccountType() == .Lawyer) {
            AppWebClient.GetLawyerProfile { (json) in
                
                guard let response = json else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: "Failed to call GetLawyerProfile api in ProfileVC.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: response[G.error].string)
                    return;
                }
                
                let valueArray = response[G.response].arrayObject
                if (valueArray != nil && valueArray!.count > 0) {
                    let accountInfo = valueArray![0] as! [String: Any]
                    AppShared.saveAccountInfo(accountInfo: accountInfo)
                    
                    self.refreshLawyerInfo(lawyerInfo: accountInfo)
                }
                
                
                // get data for graph
                self.getLawyerMonthlyProgress()
            }
        }
        else {
            AppWebClient.GetUserProfile { (json) in
                guard let response = json else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: "Failed to call GetUserProfile api in ProfileVC.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: response[G.error].string)
                    return;
                }

                SVProgressHUD.dismiss()
                
                let valueArray = response[G.response].arrayObject
                if (valueArray != nil && valueArray!.count > 0) {
                    let accountInfo = valueArray![0] as! [String: Any]
                    AppShared.saveAccountInfo(accountInfo: accountInfo)
                    
                    self.refreshUserInfo(userInfo: accountInfo)
                }

                let login = AppShared.getString(key: G.qb_login)
                let userId = login.deletingPrefix(G.prefix_user_)
                if (userId.isEmpty) {
                    return
                }
            }
        }
    }

    func editUserProfile() {
        SVProgressHUD.show()
        AppWebClient.EditUserProfile(fullName: "User 10", city: "city", state: "state", country: "country") { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call EditUserProfile api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            let message = response[G.response].string
            self.showAlert(title: "Lawyerz", msg: message!)
        }
    }
    
    func editLawyerProfile() {

        let params = [G.full_name: "",
                      G.mobile_number: "1234567890",
                      G.dob: "1987-03-31",
                      G.address: "address",
                      G.details: "details",
                      G.degree: "degree",
                      G.type: "type",
                      G.city: "city",
                      G.state: "state",
                      G.country: "country"
        ]
        
        
        var files = [LawyerzFile]()
//        for i in 0 ..< images.count {
//            let file = LawyerzFile(name: "file_\(i).png", key: "\(G.certificates)[\(i)]", data: images[i].pngData()!)
//            files.append(file)
//        }

        let image = UIImage(named: "ic_profile")!
        let certificateFile = LawyerzFile(name: "certificate.png", key: "\(G.certificates)[0]", data: image.pngData()!)
        let profilePicFile = LawyerzFile(name: "profile_pic.png", key: G.profile_pic, data: image.pngData()!)
        let bankStatementFile = LawyerzFile(name: "bank_statement.png", key: G.bank_statement, data: image.pngData()!)
        files.append(certificateFile)
        files.append(profilePicFile)
        files.append(bankStatementFile)
        
    }
    
    func getUserAppointment() {
        let strDate = AppShared.getDateString(from: Date(), format: "yyyy-MM-dd")
        
        SVProgressHUD.show()
        AppWebClient.GetUserAppointment(appointmentDate: strDate) { (json) in
            
            guard let response = json else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: "Failed to call GetUserAppointment api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                SVProgressHUD.dismiss()
                self.showAlert(msg: response[G.error].string!)
                return;
            }
            
            guard let jsonAppointments = response[G.response].array else {
                SVProgressHUD.dismiss()
                return
            }

            SVProgressHUD.dismiss()
            
            var appointments = [Appointment]()
            for info in jsonAppointments {
                let appointment = Mapper<Appointment>().map(JSONString: info.rawString()!)
                appointments.append(appointment!)
            }
        }
    }
    
    func getLawyerRating() {
        SVProgressHUD.show()
        AppWebClient.GetLawyerRating() { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetLawyerRating api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
        }
    }
    
    func getLawyerMonthlyProgress() {
        SVProgressHUD.show()
        AppWebClient.GetLawyerMonthlyProgress() { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetLawyerMonthlyProgress api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            
            self.monthValues = [Int]()
            if let jsonValues = response[G.response].array {
                for info in jsonValues {
//                    let driver = Mapper<StoreDriver>().map(JSONString: info.rawString()!)
                    let value = info.intValue
                    self.monthValues.append(value)
                }
            }
            
            let accountType: G.AccountType = AppShared.getAccountType()
            if (accountType == .Lawyer) {
                self.initGraphView()
            }
        }
    }

    func editLawyerAvailTime(fromDate: Date, toDate: Date) {
        
        let fromTime = AppShared.getDateString(from: fromDate, format: "HH:mm")
        let toTime = AppShared.getDateString(from: toDate, format: "HH:mm")
        
        SVProgressHUD.show()
        AppWebClient.EditAvailTime(availableFrom: fromTime, availableTo: toTime) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call EditAvailTime api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }

            self.fromDate = fromDate
            self.toDate = toDate
            self.lawyerInfoTimeLabel.text = "Available\n\(fromTime) - \(toTime)"
        }
    }
    
    
    // MARK: - Graph functions

    func initGraphView() {
        // Do any additional setup after loading the view.
        
        lawyerGraphView.delegate = self
        
        lawyerGraphView.chartDescription?.enabled = false
        
        lawyerGraphView.drawBarShadowEnabled = false
        lawyerGraphView.highlightFullBarEnabled = false
        
        let l = lawyerGraphView.legend
        l.wordWrapEnabled = true
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
//        chartView.legend = l

        let rightAxis = lawyerGraphView.rightAxis
        rightAxis.axisMinimum = 0
        
        let leftAxis = lawyerGraphView.leftAxis
        leftAxis.axisMinimum = 0
        
        let xAxis = lawyerGraphView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.granularity = 1
        xAxis.valueFormatter = self
        
        self.setChartData()
    }
    
    func setChartData() {
        let data = CombinedChartData()
        data.lineData = generateLineData()
        
        lawyerGraphView.xAxis.axisMaximum = data.xMax + 0.25
        
        lawyerGraphView.data = data
    }
    
    func generateLineData() -> LineChartData {
        let entries = (0..<ITEM_COUNT).map { (i) -> ChartDataEntry in
//            return ChartDataEntry(x: Double(i) + 0.5, y: Double(arc4random_uniform(15) + 5))
            return ChartDataEntry(x: Double(i) + 0.5, y: Double(self.monthValues[i]))
        }
        
        let set = LineChartDataSet(entries: entries, label: "Line DataSet")
        set.setColor(G.greenGraphColor)
        set.lineWidth = 2.5
        set.setCircleColor(UIColor.clear)
        set.circleRadius = 2.3
        set.circleHoleRadius = 2.3
        set.fillColor = G.greenGraphColor
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = .systemFont(ofSize: 10)
        set.valueTextColor = UIColor.clear
        
        set.axisDependency = .left
        
        return LineChartData(dataSet: set)
    }
}


extension ProfileVC: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value) % months.count]
    }
}


extension ProfileVC: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}
