//
//  AppointmentsVC.swift
//  Lawyer
//
//  Created by Admin on 11/1/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class AppointmentsVC: UIViewController {
    
    @IBOutlet weak var monthHeaderWrapper: UIView!
    @IBOutlet weak var monthCollectionView: UICollectionView!
    @IBOutlet weak var dateHeaderWrapper: UIView!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    @IBOutlet weak var appointmentsTableView: UITableView!
    @IBOutlet weak var appointmentsTableViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    var year: Int?
    var month: Int?
    var date: Int?
    var selectedDate: String {
        get {
            if let year = year, let month = month, let date = date {
                return String(format: "%d-%02d-%02d", year, month, date)
            } else {
                return AppShared.getDateString(from: Date(), format: "yyyy-MM-dd")
            }
        }
    }
    
    var datesOfMonth: Range<Int>?
    
    var totalAppointments = [Appointment]()
    var appointments = [Appointment]()
    
    var notificationToBeShown: Notification?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        getUserAppointment()
        getAllAppointment()
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
        
        self.title = "Appointments"
        
        let curDate = Date()
        let calendar = Calendar.current
        year = calendar.component(.year, from: curDate)
        month = calendar.component(.month, from: curDate)
        date = calendar.component(.day, from: curDate)
        
        notificationToBeShown = Notification(notificationId: "0",
                                             lawyerId: "",
                                             appointmentDate: String(format: "%d-%02d-%02d", year!, month!, date!),
                                             time: "",
                                             fullName: "",
                                             userImageUrl: "")
        
        reloadDaysOf(month: month!)
    }
    
    func updateWrapper() {
        self.appointmentsTableViewBottom.constant = self.view.frame.width * 100.0 / 375.0 - 20.0
        self.view.layoutIfNeeded()
    }
    
    @IBAction func tapDotMenuButton(_ sender: UIButton) {
    }
    
    @IBAction func tapDateButton(_ sender: UIButton) {
    }
    
    func reloadDaysOf(month: Int) {
        var dateComponents = DateComponents()
        dateComponents.year = self.year!
        dateComponents.month = month
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)
        
        self.datesOfMonth = calendar.range(of: .day, in: .month, for: date!)
        self.dateCollectionView.reloadData()
    }
    
    func loadTestAppointments() {
        totalAppointments = [Appointment]()
        
        for _ in 0 ..< 5 {
            totalAppointments.append(Appointment(fullName: "Mohd. Al Ameri", date: "", time: "Sunday 21 Dec at 12:00pm", userImageUrl: ""))
        }
        
        self.appointmentsTableView.reloadData()
    }
    
    func setMonthToCenter() {
        var offsetX: CGFloat = CGFloat(month! - 1) * 100.0 + 50.0 - view.frame.width / 2
        if (offsetX < 0.0) {
            offsetX = 0.0
        }
        
        let contentWidth: CGFloat = 12 * 100.0
        if (offsetX + view.frame.width > contentWidth) {
            offsetX = contentWidth - view.frame.width
        }
        monthCollectionView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: true)
    }
    
    func setDateToCenter() {
        var offsetX: CGFloat = CGFloat(date! - 1) * 69.0 + 34.5 - view.frame.width / 2
        if (offsetX < 0.0) {
            offsetX = 0.0
        }
        
        let contentWidth: CGFloat = CGFloat(datesOfMonth!.count) * 69.0 + 10.0
        if (offsetX + view.frame.width > contentWidth) {
            offsetX = contentWidth - view.frame.width
        }
        dateCollectionView.setContentOffset(CGPoint(x: offsetX, y: 0.0), animated: true)
    }
    
    func refreshAppointments() {
        if let notification = notificationToBeShown {
            let appointmentDate = notification.appointmentDate
            let dateComponents = appointmentDate!.split(separator: "-")
            
            month = Int(String(dateComponents[1]))
            monthCollectionView.reloadData()
            setMonthToCenter()
            
            date = Int(String(dateComponents[2]))
            reloadDaysOf(month: month!)
            setDateToCenter()
            
            appointments = getAppointmentsForDate(date: appointmentDate!)
            
            notificationToBeShown = nil
        }
        else {
            appointments = getAppointmentsForDate(date: selectedDate)
        }
        appointmentsTableView.reloadData()
        
        showNoResultLabel(label: noResultLabel, show: appointments.count < 1, message: G.No_record_found)
    }
    
    func getAppointmentsForDate(date: String) -> [Appointment] {
        var result = [Appointment]()
        
        if (totalAppointments.count > 0) {
            for (_, value) in totalAppointments.enumerated() {
                if value.localDate == date {
                    result.append(value)
                }
            }
        }
        
        return result
    }
    
    
    // MARK: - API functions
    
    func getUserAppointment() {
        let strDate = AppShared.getDateString(from: Date(), format: "yyyy-MM-dd")
        
        SVProgressHUD.show()
        AppWebClient.GetUserAppointment(appointmentDate: strDate) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetUserAppointment api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string!)
                return;
            }
            
            guard let jsonAppointments = response[G.response].array else {
                self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                return
            }
            
            self.appointments = [Appointment]()
            for info in jsonAppointments {
                let appointment = Mapper<Appointment>().map(JSONString: info.rawString()!)
                self.appointments.append(appointment!)
            }
            self.appointmentsTableView.reloadData()
            
            self.showNoResultLabel(label: self.noResultLabel, show: self.appointments.count < 1, message: G.No_record_found)
        }
    }
    
    func getAllAppointment() {
        
        SVProgressHUD.show()
        
        let accountType = AppShared.getAccountType()
        if (accountType == .Lawyer) {
            AppWebClient.GetLawyerAllAppointment() { (json) in
                SVProgressHUD.dismiss()
                
                guard let response = json else {
                    self.showAlert(msg: "Failed to call GetLawyerAllAppointment api.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    self.showAlert(msg: response[G.error].string!)
                    return;
                }
                
                guard let jsonAppointments = response[G.response].array else {
                    self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                    return
                }
                
                self.totalAppointments = [Appointment]()
                for info in jsonAppointments {
                    let appointment = Mapper<Appointment>().map(JSONString: info.rawString()!)
                    self.totalAppointments.append(appointment!)
                }
                
                self.refreshAppointments()
            }
        }
        else if (accountType == .User) {
            AppWebClient.GetUserAllAppointment() { (json) in
                SVProgressHUD.dismiss()
                
                guard let response = json else {
                    self.showAlert(msg: "Failed to call GetUserAllAppointment api.")
                    return;
                }
                
                guard response[G.status].string!.lowercased() == G.success else {
                    self.showAlert(msg: response[G.error].string!)
                    return;
                }
                
                guard let jsonAppointments = response[G.response].array else {
                    self.showNoResultLabel(label: self.noResultLabel, show: true, message: response[G.response].string)
                    return
                }
                
                self.totalAppointments = [Appointment]()
                for info in jsonAppointments {
                    let appointment = Mapper<Appointment>().map(JSONString: info.rawString()!)
                    self.totalAppointments.append(appointment!)
                }
                
                self.refreshAppointments()
            }
        }
    }
}


extension AppointmentsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
        
        // Configure the cell...
        
        let appointment = self.appointments[indexPath.row]
        cell.nameLabel.text = appointment.fullName!
        cell.timeLabel.text = "\(appointment.date!) \(appointment.time!)"
        cell.descLabel.text = appointment.desc!
        cell.statusImageView.image = UIImage(named: "ic_status_active")

        if let userImageUrl = appointment.userImageUrl, !userImageUrl.isEmpty {
            cell.userImageView.sd_setImage(with: URL(string: appointment.userImageUrl!), completed: nil)
        }
        else {
            cell.userImageView.image = UIImage(named: "ic_avatar_1")
        }
        
        return cell
    }
}


extension AppointmentsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension AppointmentsVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if (collectionView == monthCollectionView) {
            return 12
        }
        else {
            if (datesOfMonth == nil) {
                return 31
            }
            return datesOfMonth!.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == monthCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthHeaderCell", for: indexPath) as! MonthHeaderCell
            
            let df: DateFormatter = DateFormatter()
            let monthName = df.monthSymbols![indexPath.row]
            
            cell.monthNameLabel.text = monthName
            cell.isSelected = month == indexPath.row + 1

            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateHeaderCell", for: indexPath) as! DateHeaderCell

            cell.dateButton.setTitle("\(indexPath.row + 1)", for: .normal)
            cell.isSelected = date == indexPath.row + 1
            
            return cell
        }
    }
    
}


extension AppointmentsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView == monthCollectionView) {
            month = indexPath.row + 1
            monthCollectionView.reloadData()
            
            reloadDaysOf(month: month!)
        }
        else {
            date = indexPath.row + 1
            dateCollectionView.reloadData()
        }
        
        refreshAppointments()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}


extension  AppointmentsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == monthCollectionView) {
            return CGSize(width: 100.0, height: 39.0)
        }
        else {
            return CGSize(width: 59.0, height: 69.0)
        }
    }
}
