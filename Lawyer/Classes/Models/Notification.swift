//
//  Notification.swift
//  Lawyer
//
//  Created by Admin on 11/3/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class Notification: Mappable {

    var notificationId: String?
    var lawyerId: String?
    var appointmentDate: String?
    var time: String?
    var fullName: String?
    var userImageUrl: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.notificationId <- map[G.notification_id]
        self.lawyerId <- map[G.lawyer_id]
        self.appointmentDate <- map[G.appointment_date]
        self.time <- map[G.time]
        self.fullName <- map[G.full_name]
        self.userImageUrl <- map[G.profile_pic]
    }
    
    init(notificationId: String,
         lawyerId: String,
         appointmentDate: String,
         time: String,
         fullName: String,
         userImageUrl: String) {
        self.notificationId = notificationId
        self.lawyerId = lawyerId
        self.appointmentDate = appointmentDate
        self.time = time
        self.fullName = fullName
        self.userImageUrl = userImageUrl
    }
}
