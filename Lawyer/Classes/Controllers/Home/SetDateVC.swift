//
//  SetDateVC.swift
//  Lawyer
//
//  Created by Admin on 11/8/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import FSCalendar


class AvailableTimeCell: UICollectionViewCell {
    
    @IBOutlet weak var timeButton: UIButton!
    
}


class SetDateVC: UIViewController {

    @IBOutlet weak var topicWrapper: UIView!
    @IBOutlet weak var topicField: UITextField!
    
    @IBOutlet weak var calendarWrapper: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var timeWrapper: UIView!
    
    @IBOutlet weak var timesCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!
    
    var lawyerId: String?
    
    var selectedTimeIndex = -1
    var availableTimes = [String]()
    
    var date: Date = Date()
    var time: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
        
        getAvailableTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        (self.tabBarController as! LawyerTabVC).showTabView(show: false)
        AppManager.shared.mainTabVC.showTabView(show: false)
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
        self.title = "Select time and date"
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
    }
    
    func updateWrapper() {
        
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapTimeButton(_ sender: UIButton) {
        sender.isSelected = true
        
        time = sender.title(for: .normal)
        
        selectedTimeIndex = sender.tag
        timesCollectionView.reloadData()
        
        checkEnableDoneButton()
    }
    
    func deselectTimeButtons() {
        
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {
        addAppointment()
    }
    
    func checkEnableDoneButton() {
        guard (self.time != nil) else {
            self.doneButton.isEnabled = false
            return
        }
        
        self.doneButton.isEnabled = true
    }
    
    func updateTimesWithDate(date: Date) {
        self.date = date
        
        self.checkEnableDoneButton()
    }

    
    // MARK: - API functions
    
    func addAppointment() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let strDate = df.string(from: self.date)
        
        SVProgressHUD.show()
        AppWebClient.AddAppointment(lawyerId: lawyerId!, appointmentDate: strDate, time: time!, mobileNo: "1234567890") { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call AddAppointment api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.response].string)
                return;
            }
            
            let message = response[G.response].string
//            self.showAlert(msg: message!) { (action) in
                self.navigationController?.popViewController(animated: true)
//            }
            
        }
    }
    
    func getAvailableTime() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let strDate = df.string(from: self.date)
        
        SVProgressHUD.show()
        AppWebClient.GetAvailableTime(date: strDate, lawyerId: lawyerId!) { (json) in
            SVProgressHUD.dismiss()
            
            guard let response = json else {
                self.showAlert(msg: "Failed to call GetAvailableTime api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                self.showAlert(msg: response[G.error].string)
                return;
            }

            guard let jsonTimes = response[G.response].array else {
                self.showAlert(msg: response[G.response].string)
                return
            }
            
            self.availableTimes = [String]()
            for time in jsonTimes {
                self.availableTimes.append(time.string!)
            }
            
            self.timesCollectionView.reloadData()

            self.checkEnableDoneButton()
        }
    }
}


extension SetDateVC: FSCalendarDataSource {
    
}


extension SetDateVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        updateTimesWithDate(date: date)
    }
}


extension SetDateVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableTimes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvailableTimeCell", for: indexPath) as! AvailableTimeCell
        
        // Configure the cell
        
        let time = availableTimes[indexPath.row]
        cell.timeButton.setTitle(time, for: .normal)
        cell.timeButton.tag = indexPath.row
        cell.timeButton.isSelected = selectedTimeIndex == cell.timeButton.tag
        
        return cell
    }
}


extension SetDateVC: UICollectionViewDelegate {
    
}


extension SetDateVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width / 4.0 - 10.0,
                          height: 45.0)
        return size
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}
