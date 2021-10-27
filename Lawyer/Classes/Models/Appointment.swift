//
//  Appointment.swift
//  Lawyer
//
//  Created by Admin on 11/4/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class Appointment: Mappable {
    
    var fullName: String?
    var date: String?
    var time: String?
    var desc: String?
    var userImageUrl: String?
    
    var localDate: String? {
        get {
            let dateString = "\(date!) \(time!.count > 5 ? String(time!.prefix(upTo: time!.firstIndex(of: "-")!)) : time!):00"
            let localDateString = AppShared.getLocalDate(fromDateString: dateString, inTimeZone: "UTC", format: "yyyy-MM-dd")
            return localDateString
        }
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.fullName <- map[G.full_name]
        self.date <- map[G.appointment_date]
        self.time <- map[G.time]
        self.desc = "Coming up your next appointment with"
        self.userImageUrl <- map[G.profile_pic]
    }
    
    init(fullName: String,
         date: String,
         time: String,
         userImageUrl: String) {
        
        self.fullName = fullName
        self.date = date
        self.time = time
        self.desc = "Coming up your next appointment with"
        self.userImageUrl = userImageUrl
        
    }
}
