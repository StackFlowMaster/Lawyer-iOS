//
//  HomeVC.swift
//  Lawyer
//
//  Created by Admin on 10/31/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import SDWebImage

class HomeVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var searchWrapper: UIView!
    @IBOutlet weak var searchBgViewNormal: UIImageView!
    @IBOutlet weak var searchBgViewExpand: UIImageView!
    @IBOutlet weak var searchMoreButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var filterButtonCountry: UIButton!
    @IBOutlet weak var filterButtonLawyer: UIButton!
    @IBOutlet weak var filterButtonRate: UIButton!
    @IBOutlet weak var filterButtonPrice: UIButton!
    
    @IBOutlet weak var categoryButtonNearToYou: UIButton!
    @IBOutlet weak var categoryButtonTopRated: UIButton!
    @IBOutlet weak var categoryButtonOnline: UIButton!
    
    @IBOutlet weak var tableViewNearToYou: UITableView!
    @IBOutlet weak var tableViewTopRated: UITableView!
    @IBOutlet weak var tableViewOnline: UITableView!
    @IBOutlet weak var tableViewSearchResult: UITableView!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    @IBOutlet weak var searchWrapperHeight: NSLayoutConstraint!
    @IBOutlet weak var searchButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var searchButtonCenterX: NSLayoutConstraint!
    @IBOutlet weak var searchButtonCenterY: NSLayoutConstraint!
    @IBOutlet weak var homeTableViewBottom: NSLayoutConstraint!
    

    @IBOutlet weak var priceWrapperToolBar: UIToolbar!
    @IBOutlet weak var priceWrapper: UIView!
    @IBOutlet weak var priceWrapperBottom: NSLayoutConstraint!
    @IBOutlet weak var fromPriceTableView: UITableView!
    @IBOutlet weak var toPriceTableView: UITableView!

    private let chatManager = ChatManager.instance
    
    var lawyersNearToYou = [Lawyer]()
    var lawyersTopRated = [Lawyer]()
    var lawyersOnline = [Lawyer]()
    var lawyersSearchResult = [Lawyer]()
    
    let prices = ["0", "500", "1K", "5K", "10K", "10K+"]
    var fromPrice: Int = 0
    var toPrice: Int = 0
    var selectedFromPrice: Int = 0
    var selectedToPrice: Int = 0
    
    var recipientAvatarUrl: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ShowUserVC") {
            let vc = segue.destination as! UserVC
            vc.lawyer = sender as? Lawyer
        }
        else if (segue.identifier == "ShowCountriesVC") {
            let vc = segue.destination as! CountriesVC
            vc.selectedCountryIndex = filterButtonCountry.tag
        }
        else if (segue.identifier == "ShowLawyerTypes") {
            let vc = segue.destination as! LawyerTypesVC
            vc.unwindSegueIdentifier = "UnwindToHomeVCWithType"
        }
        else if (segue.identifier == "ShowChatVC") {
            let vc = segue.destination as! ChatVC
            vc.dialogID = sender as? String
            vc.recipientAvatarUrl = recipientAvatarUrl
        }
    }
    

    func initUI() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.clear()
        
        let accountType = AppShared.getAccountType()
        backButton.alpha = accountType == .Guest ? 1.0 : 0.0
        
        filterButtonRate.isHidden = true
        filterButtonPrice.isHidden = true
        
        updateWrapper()
    }
    
    func updateWrapper() {
        let width = self.view.frame.width * 302.0 / 375.0
        let minHeight = width * 45.0 / 302.0
        let maxHeight = width * 233.0 / 302.0
//        let maxHeight = width * 180.0 / 302.0
        let height = self.searchMoreButton.isSelected ? maxHeight : minHeight
        print("width = \(width) : height = \(height)")
        self.searchWrapperHeight.constant = height
        
        let searchButtonWidth = self.searchMoreButton.isSelected ? width * 82.0 / 302.0 : width * 62.0 / 302.0
        self.searchButtonWidth.constant = searchButtonWidth
        
        let offsetX = self.searchMoreButton.isSelected ? 0.0 : (width - self.searchButtonWidth.constant) / 2 - (minHeight - self.searchButton.frame.height) / 2
        let offsetY = self.searchMoreButton.isSelected ? (maxHeight - self.searchButton.frame.height) / 2 - 20.0 : 0.0
        self.searchButtonCenterX.constant = offsetX
        self.searchButtonCenterY.constant = offsetY
        
        self.homeTableViewBottom.constant = self.view.frame.width * 100.0 / 375.0 - 20.0
        
        self.view.layoutIfNeeded()
    }
    
    func showSearchOptions(show: Bool) {
        searchMoreButton.isSelected = show
        
        UIView.animate(withDuration: 0.2, animations: {
            self.searchBgViewNormal.alpha = show ? 0.0 : 1.0
            self.searchBgViewExpand.alpha = show ? 1.0 : 0.0
            self.filterButtonCountry.alpha = show ? 1.0 : 0.0
            self.filterButtonLawyer.alpha = show ? 1.0 : 0.0
            self.filterButtonRate.alpha = show ? 1.0 : 0.0
            self.filterButtonPrice.alpha = show ? 1.0 : 0.0
            
            self.updateWrapper()
            
        }) { (finished) in
            
        }
    }
    
    @IBAction func tapSearchMoreButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        showSearchOptions(show: sender.isSelected)
    }
    
    @IBAction func tapSearchButton(_ sender: UIButton) {
        
        var name = searchField.text
        if (name == nil) {
            name = ""
        }
        
        var country = filterButtonCountry.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (country == "Country") {
            country = ""
        }
        
        var lawyerType = filterButtonLawyer.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (lawyerType == "lawyer type") {
            lawyerType = ""
        }
        
        
        let normalFont = UIFont.systemFont(ofSize: 16.0)
        
        categoryButtonNearToYou.isSelected = false
        categoryButtonTopRated.isSelected = false
        categoryButtonOnline.isSelected = false
        
        categoryButtonNearToYou.titleLabel?.font = normalFont
        categoryButtonTopRated.titleLabel?.font = normalFont
        categoryButtonOnline.titleLabel?.font = normalFont
        
        tableViewNearToYou.alpha = 0.0
        tableViewTopRated.alpha = 0.0
        tableViewOnline.alpha = 0.0
        tableViewSearchResult.alpha = 1.0
        
        showNoResultLabel(label: self.noResultLabel, show: false, message: nil)

        showSearchOptions(show: false)
        
        
        SVProgressHUD.show()
        AppWebClient.Search_lawyers(name: name!, country: country!, lawyerType: lawyerType!, fromValue: "", toValue: "", topRated: "") { (json) in
            SVProgressHUD.dismiss()

            self.searchField.text = nil
            self.filterButtonCountry.tag = 0
            self.filterButtonCountry.setTitle("Country", for: .normal)
            self.filterButtonLawyer.setTitle("lawyer type", for: .normal)
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call Search_lawyers api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                if let errMessage = response[G.response].string, errMessage.lowercased() == G.No_record_found.lowercased() {
                    self.showNoResultLabel(label: self.noResultLabel, show: true, message: G.No_record_found)
                }
                else {
                    self.showAlert(msg: response[G.response].string)
                }
                return;
            }
            
            guard let jsonLawyers = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.lawyersSearchResult = [Lawyer]()
            for info in jsonLawyers {
                let lawyer = Mapper<Lawyer>().map(JSONString: info.rawString()!)
                self.lawyersSearchResult.append(lawyer!)
            }
            self.tableViewSearchResult.reloadData()

            self.showNoResultLabel(label: self.noResultLabel, show: self.lawyersSearchResult.count < 1, message: G.No_record_found)
        }
    }
    
    @IBAction func tapSearchFilterButton(_ sender: UIButton) {
        if (sender == filterButtonCountry) {
            performSegue(withIdentifier: "ShowCountriesVC", sender: nil)
        }
        else if (sender == filterButtonLawyer) {
            performSegue(withIdentifier: "ShowLawyerTypes", sender: nil)
        }
    }
    
    @IBAction func tapCategoryButton(_ sender: UIButton) {
        let normalFont = UIFont.systemFont(ofSize: 16.0)
        let selectedFont = UIFont.systemFont(ofSize: 20.0)
        
        self.categoryButtonNearToYou.isSelected = sender == self.categoryButtonNearToYou
        self.categoryButtonTopRated.isSelected = sender == self.categoryButtonTopRated
        self.categoryButtonOnline.isSelected = sender == self.categoryButtonOnline
        
        self.categoryButtonNearToYou.titleLabel?.font = self.categoryButtonNearToYou.isSelected ? selectedFont : normalFont
        self.categoryButtonTopRated.titleLabel?.font = self.categoryButtonTopRated.isSelected ? selectedFont : normalFont
        self.categoryButtonOnline.titleLabel?.font = self.categoryButtonOnline.isSelected ? selectedFont : normalFont
        
        tableViewNearToYou.alpha = categoryButtonNearToYou.isSelected ? 1.0 : 0.0
        tableViewTopRated.alpha = categoryButtonTopRated.isSelected ? 1.0 : 0.0
        tableViewOnline.alpha = categoryButtonOnline.isSelected ? 1.0 : 0.0
        tableViewSearchResult.alpha = 0.0
        
        if (sender == self.categoryButtonNearToYou) {
            getNearLawyers()
        }
        else if (sender == self.categoryButtonTopRated) {
            getTopRatedLawyers()
        }
        else if (sender == self.categoryButtonOnline) {
            getOnlineLawyers()
        }
    }
    
    @IBAction func tapActionButton(_ sender: UIButton) {
        let accountType = AppShared.getAccountType()
        if accountType == .Guest {
            showLoginAlert()
            return
        }
        
        
        var lawyer: Lawyer?
        
        if (tableViewSearchResult.alpha == 1.0) {
            lawyer = lawyersSearchResult[sender.tag]
        }
        else {
            if (tableViewNearToYou.alpha == 1.0) {
                lawyer = lawyersNearToYou[sender.tag]
            }
            else if (tableViewTopRated.alpha == 1.0) {
                lawyer = lawyersTopRated[sender.tag]
            }
            else if (tableViewOnline.alpha == 1.0) {
                lawyer = lawyersOnline[sender.tag]
            }
        }
        
        guard let selectedLawyer = lawyer else {
            return
        }
        
        if selectedLawyer.status == .Active {
            guard let userId = selectedLawyer.lawyerId else {
                return
            }
            
            SVProgressHUD.show()
            chatManager.loadUser(userId) { (user) in
                print("user = \(user?.email ?? "")")
                
                guard let user = user else {
                    SVProgressHUD.dismiss()
                    self.showAlert(msg: "No exist QB account of selected Lawyer")
                    return
                }
                
                self.recipientAvatarUrl = selectedLawyer.imageUrl
                self.moveToChat(user: user)
            }
        }
        else {
            goToAppointment(notification: nil)
        }
    }
    
    func showLoginAlert() {
        let alert = UIAlertController(title: nil, message: "Please login first", preferredStyle: .alert)
        alert.view.tintColor = G.greenTextColor
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
            self.tabBarController?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func moveToChat(user: QBUUser) {
        
        if let dialog = chatManager.storage.privateDialog(opponentID: user.id) {
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)
            return
        }
        
        SVProgressHUD.show()
        chatManager.createPrivateDialog(withOpponent: user, completion: { (response, dialog) in
            guard let dialog = dialog else {
                SVProgressHUD.dismiss()
                if let error = response?.error {
                    self.showAlert(msg: error.error?.localizedDescription)
                }
                return
            }

            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "ShowChatVC", sender: dialog.id)
        })
    }
    
    func goToAppointment(notification: Notification?) {

        let mainTabVC = AppManager.shared.mainTabVC
        let appointmentsNVC: AppointmentsNVC = mainTabVC.viewControllers![1] as! AppointmentsNVC
        if let appointmentsVC: AppointmentsVC = appointmentsNVC.topViewController as? AppointmentsVC {
            appointmentsVC.notificationToBeShown = notification
        }
        mainTabVC.tapTabButton(mainTabVC.tabButtonAppointment)
    }
    
    func showPricePicker(show: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.priceWrapperBottom.constant = show ? 0.0 : -300.0
            self.view.layoutIfNeeded()
        }) { (finished) in
            
        }
    }
    
    @IBAction func tapPriceCancelButton(_ sender: UIBarButtonItem) {
//        self.timeField.infoField.resignFirstResponder()
        showPricePicker(show: false)
    }
    
    @IBAction func tapPriceDoneButton(_ sender: UIBarButtonItem) {
//        let fromTime = getTime(date: fromTimePicker.date)
//        let toTime = getTime(date: toTimePicker.date)
        
        fromPrice = selectedFromPrice
        toPrice = selectedToPrice
        
        filterButtonPrice.setTitle("\(fromPrice) - \(toPrice)", for: .normal)
        
//        self.timeField.infoField.resignFirstResponder()
        showPricePicker(show: false)
    }
    
    @IBAction func unwindToHomeVC(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
        
        if (unwindSegue.identifier == "UnwindToHomeVCWithCountry") {
            let sourceVC = unwindSegue.source as! CountriesVC
            let selectedCountryIndex = sourceVC.selectedCountryIndex
            filterButtonCountry.tag = selectedCountryIndex
            
            let selectedCountry = AppManager.shared.countries[selectedCountryIndex]
            filterButtonCountry.setTitle(selectedCountry.name, for: .normal)
        }
        else if (unwindSegue.identifier == "UnwindToHomeVCWithType") {
            let typesVC = unwindSegue.source as! LawyerTypesVC
            let type = typesVC.selectedLawyerType
            if (type != nil) {
                filterButtonLawyer.setTitle(type?.type, for: .normal)
            }
        }
    }
    
    func loadUsers() {
        getNearLawyers()
    }
    
    func loadTestUsers() {
        lawyersNearToYou = [Lawyer]()
        
        lawyersNearToYou.append(Lawyer.lawyer1())
        lawyersNearToYou.append(Lawyer.lawyer2())
        lawyersNearToYou.append(Lawyer.lawyer3())
        lawyersNearToYou.append(Lawyer.lawyer4())
        lawyersNearToYou.append(Lawyer.lawyer5())
        lawyersNearToYou.append(Lawyer.lawyer1())
        lawyersNearToYou.append(Lawyer.lawyer2())
        lawyersNearToYou.append(Lawyer.lawyer3())
        lawyersNearToYou.append(Lawyer.lawyer4())
        lawyersNearToYou.append(Lawyer.lawyer5())
        
        tableViewNearToYou.reloadData()
    }
    
    func getProfile() {
        let accountType = AppShared.getAccountType()
        switch accountType {
        case .Lawyer:
            getLawyerProfile()
            break
        case .User:
            getUserProfile()
            break
        default:
            break
        }
    }

    // MARK: - API functions
    
    func getNearLawyers() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard appDelegate.userLocation != nil else {
            return
        }

        self.showNoResultLabel(label: self.noResultLabel, show: false, message: nil)
        
        SVProgressHUD.show()
        AppWebClient.GetNearLawyers(latitude:"\(String(describing: appDelegate.userLocation!.coordinate.latitude))", longitude: "\(String(describing: appDelegate.userLocation!.coordinate.longitude))") { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetNearLawyers api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let jsonLawyers = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.lawyersNearToYou = [Lawyer]()
            for info in jsonLawyers {
                let lawyer = Mapper<Lawyer>().map(JSONString: info.rawString()!)
                self.lawyersNearToYou.append(lawyer!)
            }
            self.tableViewNearToYou.reloadData()

            self.showNoResultLabel(label: self.noResultLabel, show: self.lawyersNearToYou.count < 1, message: G.No_record_found)
        }
    }
    
    func getTopRatedLawyers() {
        self.showNoResultLabel(label: self.noResultLabel, show: false, message: nil)
        
        SVProgressHUD.show()
        AppWebClient.GetTopRatedLawyers { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetTopRatedLawyers api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let jsonLawyers = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.lawyersTopRated = [Lawyer]()
            for info in jsonLawyers {
                let lawyer = Mapper<Lawyer>().map(JSONString: info.rawString()!)
                self.lawyersTopRated.append(lawyer!)
            }
            self.tableViewTopRated.reloadData()
            
            self.showNoResultLabel(label: self.noResultLabel, show: self.lawyersTopRated.count < 1, message: G.No_record_found)
        }
    }
    
    func getOnlineLawyers() {
        self.showNoResultLabel(label: self.noResultLabel, show: false, message: nil)
        
        SVProgressHUD.show()
        AppWebClient.GetOnlineLawyer { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetOnlineLawyer api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            guard let jsonLawyers = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.lawyersOnline = [Lawyer]()
            for info in jsonLawyers {
                let lawyer = Mapper<Lawyer>().map(JSONString: info.rawString()!)
                self.lawyersOnline.append(lawyer!)
            }
            self.tableViewOnline.reloadData()

            self.showNoResultLabel(label: self.noResultLabel, show: self.lawyersOnline.count < 1, message: G.No_record_found)
        }
    }
    
    func getLawyerProfile() {
        SVProgressHUD.show()
        AppWebClient.GetLawyerProfile { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetLawyerProfile api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            let valueArray = response[G.response].arrayObject
            if (valueArray != nil && valueArray!.count > 0) {
                let accountInfo = valueArray![0] as! [String: Any]
                AppShared.saveAccountInfo(accountInfo: accountInfo)
            }
        }
    }
    
    func getUserProfile() {
        SVProgressHUD.show()
        AppWebClient.GetUserProfile { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetUserProfile api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
            let valueArray = response[G.response].arrayObject
            if (valueArray != nil && valueArray!.count > 0) {
                let accountInfo = valueArray![0] as! [String: Any]
                AppShared.saveAccountInfo(accountInfo: accountInfo)
            }
        }
    }

    func editAccountLocation() {
        SVProgressHUD.show()
        AppWebClient.EditUserLocation(latitude: "37.785834", longitude: "-122.406417") { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call EditUserLocation api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
        }
    }
    
    func getLawyerType() {
        SVProgressHUD.show()
        AppWebClient.GetLawyersType { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetLawyersType api in HomeVC.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }
            
        }
    }
}


extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if (tableView == tableViewNearToYou) {
            count = lawyersNearToYou.count
        }
        else if (tableView == tableViewTopRated) {
            count = lawyersTopRated.count
        }
        else if (tableView == tableViewOnline) {
            count = lawyersOnline.count
        }
        else if (tableView == tableViewSearchResult) {
            count = lawyersSearchResult.count
        }
        else {
            count = prices.count - 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: LawyerCell?
        var lawyer: Lawyer?
        
        if (tableView == tableViewNearToYou) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LawyerNearToYouCell", for: indexPath) as? LawyerCell
            lawyer = lawyersNearToYou[indexPath.row]

            if let imageUrl = lawyer!.imageUrl, !imageUrl.isEmpty {
                cell!.profileImageView!.sd_setImage(with: URL(string: imageUrl), completed: nil)
            }
            else {
                cell?.profileImageView.image = UIImage(named: "ic_avatar_1")
            }
        }
        else if (tableView == tableViewTopRated) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LawyerTopRatedCell", for: indexPath) as? LawyerCell
            lawyer = lawyersTopRated[indexPath.row]
            
            if let imageUrl = lawyer!.imageUrl, !imageUrl.isEmpty {
                cell!.profileImageView!.sd_setImage(with: URL(string: imageUrl), completed: nil)
            }
            else {
                cell?.profileImageView.image = UIImage(named: "ic_avatar_1")
            }
        }
        else if (tableView == tableViewOnline) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LawyerOnlineCell", for: indexPath) as? LawyerCell
            lawyer = lawyersOnline[indexPath.row]
            
            if let imageUrl = lawyer!.imageUrl, !imageUrl.isEmpty {
                cell!.profileImageView!.sd_setImage(with: URL(string: imageUrl), completed: nil)
            }
            else {
                cell?.profileImageView.image = UIImage(named: "ic_avatar_1")
            }
        }
        else if (tableView == tableViewSearchResult) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LawyerSearchResultCell", for: indexPath) as? LawyerCell
            lawyer = lawyersSearchResult[indexPath.row]
            
            if let imageUrl = lawyer!.imageUrl, !imageUrl.isEmpty {
                cell!.profileImageView!.sd_setImage(with: URL(string: imageUrl), completed: nil)
            }
            else {
                cell?.profileImageView.image = UIImage(named: "ic_avatar_1")
            }
        }
        else if (tableView == fromPriceTableView) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LawyerSearchResultCell", for: indexPath) as? LawyerCell
            lawyer = lawyersSearchResult[indexPath.row]
            
            if let imageUrl = lawyer!.imageUrl, !imageUrl.isEmpty {
                cell!.profileImageView!.sd_setImage(with: URL(string: imageUrl), completed: nil)
            }
            else {
                cell?.profileImageView.image = UIImage(named: "ic_avatar_1")
            }
        }
        else if (tableView == toPriceTableView) {
            cell = tableView.dequeueReusableCell(withIdentifier: "LawyerSearchResultCell", for: indexPath) as? LawyerCell
            lawyer = lawyersSearchResult[indexPath.row]
            
            if let imageUrl = lawyer!.imageUrl, !imageUrl.isEmpty {
                cell!.profileImageView!.sd_setImage(with: URL(string: imageUrl), completed: nil)
            }
            else {
                cell?.profileImageView.image = UIImage(named: "ic_avatar_1")
            }
        }
        
        cell!.nameLabel.text = lawyer!.full_name!
        cell!.typeLabel.text = lawyer!.lawyerType!
        cell!.ratingView.rating = lawyer!.rating!
        cell!.ratingView.alpha = 0.0
        cell?.actionButton.tag = indexPath.row
        cell!.actionButton.setImage(UIImage(named: lawyer!.status == .Active ? "btn_free_chat" : "btn_select_a_date"), for: .normal)
        cell!.statusImageView.image = lawyer!.statusImage
        
        return cell!
    }
}


extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let accountType = AppShared.getAccountType()
        if accountType == .Guest {
            showLoginAlert()
            return
        }
        
        var lawyer: Lawyer?
        if (tableView == tableViewNearToYou) {
            lawyer = lawyersNearToYou[indexPath.row]
        }
        else if (tableView == tableViewTopRated) {
            lawyer = lawyersTopRated[indexPath.row]
        }
        else if (tableView == tableViewOnline) {
            lawyer = lawyersOnline[indexPath.row]
        }
        else if (tableView == tableViewSearchResult) {
            lawyer = lawyersSearchResult[indexPath.row]
        }
        
        self.performSegue(withIdentifier: "ShowUserVC", sender: lawyer)
    }
}
