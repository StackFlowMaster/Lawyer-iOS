//
//  AppShared.swift
//  Lawyer
//
//  Created by Admin on 11/9/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class AppShared {
    static let shared = AppShared()
    
    class func getDeviceToken() -> String {
        let tokenStr = UserDefaults.standard.object(forKey: G.DeviceToken) as? String
        return tokenStr ?? ""
    }

    class func saveDeviceToken(tokenString : String) {
        UserDefaults.standard.set(tokenString, forKey: G.DeviceToken)
    }
    
    class func getAuthToken() -> String {
        let tokenStr = UserDefaults.standard.object(forKey: G.auth_token) as? String
        return tokenStr ?? ""
    }
    
    class func saveAuthToken(tokenString : String) {
        UserDefaults.standard.set(tokenString, forKey: G.auth_token)
    }
    
    class func saveUserCridentials(email : String, password : String, tokenString: String, loginType: String, qbLogin: String, qbPassword: String, qbFullname: String) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: G.email)
        defaults.set(password, forKey: G.password)
        defaults.set(tokenString, forKey: G.auth_token)
        defaults.set(loginType, forKey: G.login_type)
        defaults.set(qbLogin, forKey: G.qb_login)
        defaults.set(qbPassword, forKey: G.qb_password)
        defaults.set(qbFullname, forKey: G.qb_fullname)
    }
    
    class func clearUserCridentials() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: G.email)
        defaults.removeObject(forKey: G.password)
        defaults.removeObject(forKey: G.auth_token)
        defaults.removeObject(forKey: G.login_type)
        defaults.removeObject(forKey: G.qb_login)
        defaults.removeObject(forKey: G.qb_password)
        defaults.removeObject(forKey: G.qb_fullname)
    }
    
    class func getAccountInfo() -> [String: Any] {
        let accountInfo = UserDefaults.standard.object(forKey: G.account_info) as? [String: Any]
        return accountInfo!
    }
    
    class func saveAccountInfo(accountInfo : [String: Any]) {
        UserDefaults.standard.set(accountInfo, forKey: G.account_info)
    }
    
    class func getAccountType() -> G.AccountType {
        let defaults = UserDefaults.standard
        
        guard let loginType = defaults.string(forKey: G.login_type), !loginType.isEmpty else {
            return .Guest
        }
        
        if (loginType == G.lawyer) {
            return .Lawyer
        }
        
        return .User
    }
    
    class func getString(key: String) -> String {
        let value = UserDefaults.standard.object(forKey: key) as? String
        return value ?? ""
    }
    
    class func getAlert(title: String?, msg: String?, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertTitle = title == nil ? "Lawyerz" : title
        let alert = UIAlertController(title: alertTitle, message: msg, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: handler)
        alert.addAction(cancel)
        return alert
    }
    
    class func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    class func getDateString(from date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format

        let strDate = formatter.string(from:date)
        
        return strDate
    }
    
    class func getDateFromDateString(_ strDate: String?, inTimeZone timeZone: String?) -> Date {
        let dtFormat = DateFormatter()
        dtFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let time = NSTimeZone(abbreviation: timeZone ?? "") {
            dtFormat.timeZone = time as TimeZone
        }
        
        let date: Date = dtFormat.date(from: strDate ?? "")!
        return date
    }
    
    class func getLocalDate(fromDateString strDate: String?, inTimeZone timeZone: String?, format: String) -> String? {
        let date: Date = AppShared.getDateFromDateString(strDate, inTimeZone: timeZone)
        
        let dtFormat = DateFormatter()
        dtFormat.timeZone = NSTimeZone.system
        dtFormat.dateFormat = format
        
        let dateString = dtFormat.string(from: date)
        return dateString
    }
    
    class func getLocalTime(fromDateString strDate: String?, inTimeZone timeZone: String?, format: String) -> String? {
        let date: Date = AppShared.getDateFromDateString(strDate, inTimeZone: timeZone)
        
        let dtFormat = DateFormatter()
        dtFormat.timeZone = NSTimeZone.system
        dtFormat.dateFormat = format
        
        var dateString = dtFormat.string(from: date)
        
        let strHour = dateString.prefix(2)
        var hour = Int(strHour)
        hour = hour! > 12 ? hour! - 12 : hour
        hour = hour! < 1 ? hour! + 12 : hour
        dateString = String(format: "%02d%@", hour!, String(dateString.suffix(from: dateString.index(dateString.startIndex, offsetBy: 2))))
        
        return dateString
    }
    
    class func getLocalDateTimeIn12(fromDateString strDate: String?, inTimeZone timeZone: String?) -> String? {
        let date: Date = AppShared.getDateFromDateString(strDate, inTimeZone: timeZone)
        
        let dtFormat = DateFormatter()
        dtFormat.timeZone = NSTimeZone.system
        dtFormat.dateFormat = "yyyy-MM-dd"
        var dateString = dtFormat.string(from: date)
        
        let timeString = AppShared.getLocalTime(fromDateString: strDate, inTimeZone: timeZone, format: "HH:mm aa")
        
        dateString = "\(dateString) \(timeString!)"
//        print("===> \(strDate!) : \(dateString)")
        
        return dateString
    }
    
    class func updateLawyerStatus(liveStatus: String, showLoading: Bool = false) {
        if (showLoading) {
            SVProgressHUD.show()
        }
        
        AppWebClient.UpdateLawyerStatus(liveStatus: liveStatus) { (json) in
            if (showLoading) {
                SVProgressHUD.dismiss()
            }
            
            guard let response = json else {
                SVProgressHUD.showError(withStatus: "Failed to call UpdateLawyerStatus api.")
                return;
            }
            
            guard response[G.status].string!.lowercased() == G.success else {
                SVProgressHUD.showError(withStatus: response[G.error].string)
                return;
            }
        }
    }
}
