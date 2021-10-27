//
//  Lawyer.swift
//  Lawyer
//
//  Created by Admin on 11/2/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class Lawyer: Mappable {

    private var liveStatus: String?
    
    var lawyerId: String?
    var full_name: String?
    var lawyerType: String?
    var address: String?
    var imageUrl: String?
    var rating: Double?
    var chatStatus: Bool?
    var status: G.UserStatus?
    
    var statusImage: UIImage? {
        get {
            var image: UIImage?
            switch self.status! {
            case .Offline:
                image = UIImage(named: "ic_status_offline")
                break
            case .Invisible:
                image = UIImage(named: "ic_status_invisible")
                break
            case .Active:
                image = UIImage(named: "ic_status_active")
                break
            }
            return image
        }
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
//        self.type <- map[G.type]
        self.lawyerId <- map[G.lawyer_id]
        self.full_name <- map[G.full_name]
        self.lawyerType <- map[G.type]
        self.address <- map[G.type]
        self.imageUrl <- map[G.profile_pic]
        self.rating <- map[G.rating]
        self.chatStatus <- map[G.status]
        self.liveStatus <- map[G.live_status]
        
        if (self.chatStatus == nil) {
            chatStatus = false
        }
        if (self.liveStatus == nil) {
            liveStatus = G.Offline
        }
        if (self.rating == nil) {
            self.rating = 0.0
        }
        self.status = self.liveStatus! == G.Online ? .Active : .Offline
    }
    
    init(lawyerId: String,
         full_name: String,
         lawyerType: String,
         address: String,
         imageUrl: String,
         rating: Double,
         chatStatus: Bool,
         status: G.UserStatus) {
        self.lawyerId = lawyerId
        self.full_name = full_name
        self.lawyerType = lawyerType
        self.address = address
        self.imageUrl = imageUrl
        self.rating = rating
        self.chatStatus = chatStatus
        self.status = status
    }
    
    class func lawyer1() -> Lawyer {
        let lawyer = Lawyer(lawyerId: "1",
                            full_name: "Mohd. Al Ameri",
                            lawyerType: "Immigration Lawyer",
                            address: "Mecca, Saudi Arabia",
                            imageUrl: "ic_avatar_1",
                            rating: 5.0,
                            chatStatus: true,
                            status: .Active)
        return lawyer
    }
    
    class func lawyer2() -> Lawyer {
        let lawyer = Lawyer(lawyerId: "2",
                            full_name: "Khalid Bukhari",
                            lawyerType: "Corporate Lawyer",
                            address: "Mecca, Saudi Arabia",
                            imageUrl: "ic_avatar_2",
                            rating: 5.0,
                            chatStatus: true,
                            status: .Active)
        return lawyer
    }
    
    class func lawyer3() -> Lawyer {
        let lawyer = Lawyer(lawyerId: "3",
                            full_name: "Farah AL Mousa",
                            lawyerType: "Personal Injury Lawyer",
                            address: "Mecca, Saudi Arabia",
                            imageUrl: "ic_avatar_3",
                            rating: 5.0,
                            chatStatus: false,
                            status: .Invisible)
        return lawyer
    }
    
    class func lawyer4() -> Lawyer {
        let lawyer = Lawyer(lawyerId: "4",
                            full_name: "Salman Aldosary",
                            lawyerType: "Criminal Lawyer",
                            address: "Mecca, Saudi Arabia",
                            imageUrl: "ic_avatar_1",
                            rating: 5.0,
                            chatStatus: false,
                            status: .Offline)
        return lawyer
    }
    
    class func lawyer5() -> Lawyer {
        let lawyer = Lawyer(lawyerId: "5",
                            full_name: "Esra Al Galib",
                            lawyerType: "Family Lawyer",
                            address: "Mecca, Saudi Arabia",
                            imageUrl: "ic_avatar_5",
                            rating: 5.0,
                            chatStatus: true,
                            status: .Active)
        return lawyer
    }
}
