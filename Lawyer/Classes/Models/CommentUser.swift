//
//  CommentUser.swift
//  Lawyer
//
//  Created by Admin on 1/29/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class CommentUser: NSObject {

    private var liveStatus: String?
    
    var userId: String?
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
        self.userId <- map[G.lawyer_id]
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
    
    init(userId: String,
         full_name: String,
         lawyerType: String,
         address: String,
         imageUrl: String,
         rating: Double,
         chatStatus: Bool,
         status: G.UserStatus) {
        self.userId = userId
        self.full_name = full_name
        self.lawyerType = lawyerType
        self.address = address
        self.imageUrl = imageUrl
        self.rating = rating
        self.chatStatus = chatStatus
        self.status = status
    }
    
    class func user1() -> CommentUser {
        let user = CommentUser(userId: "1",
                               full_name: "Mohd. Al Ameri",
                               lawyerType: "Immigration Lawyer",
                               address: "Mecca, Saudi Arabia",
                               imageUrl: "ic_avatar_1",
                               rating: 5.0,
                               chatStatus: true,
                               status: .Active)
        return user
    }
    
    class func user2() -> CommentUser {
        let user = CommentUser(userId: "2",
                               full_name: "Khalid Bukhari",
                               lawyerType: "Corporate Lawyer",
                               address: "Mecca, Saudi Arabia",
                               imageUrl: "ic_avatar_2",
                               rating: 5.0,
                               chatStatus: true,
                               status: .Active)
        return user
    }
    
    class func user3() -> CommentUser {
        let user = CommentUser(userId: "3",
                               full_name: "Farah AL Mousa",
                               lawyerType: "Personal Injury Lawyer",
                               address: "Mecca, Saudi Arabia",
                               imageUrl: "ic_avatar_3",
                               rating: 5.0,
                               chatStatus: false,
                               status: .Invisible)
        return user
    }
    
    class func user4() -> CommentUser {
        let user = CommentUser(userId: "4",
                               full_name: "Salman Aldosary",
                               lawyerType: "Criminal Lawyer",
                               address: "Mecca, Saudi Arabia",
                               imageUrl: "ic_avatar_1",
                               rating: 5.0,
                               chatStatus: false,
                               status: .Offline)
        return user
    }
    
    class func user5() -> CommentUser {
        let user = CommentUser(userId: "5",
                               full_name: "Esra Al Galib",
                               lawyerType: "Family Lawyer",
                               address: "Mecca, Saudi Arabia",
                               imageUrl: "ic_avatar_5",
                               rating: 5.0,
                               chatStatus: true,
                               status: .Active)
        return user
    }
}
