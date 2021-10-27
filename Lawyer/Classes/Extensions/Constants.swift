//
//  Constants.swift
//  Lawyer
//
//  Created by Admin on 11/1/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class Constants {
    
    class var QB_USERS_ENVIROMENT: String {
        
#if DEBUG
        return "dev"
#elseif QA
        return "qbqa"
#else
    assert(false, "Not supported build configuration")
    return ""
#endif
        
    }
}


struct G {
    
    static let greenColor = UIColor(red: 0.0, green: 222/255.0, blue: 86/255.0, alpha: 1.0)
    static let greenTextColor = UIColor(red: 73/255.0, green: 235/255.0, blue: 185/255.0, alpha: 1.0)
    static let greenGraphColor = UIColor(red: 60/255.0, green: 234/255.0, blue: 180/255.0, alpha: 1.0)
    
    static let FacebookAppID = ""
    static let GoogleClientID = ""
    static let GoogleReversedClientID = ""
    
    
    static let GoogleMapAPIKey = ""
    
    
    static let HTTP_AUTH_USERNAME = ""
    static let HTTP_AUTH_PASSWORD = ""
    
    // QB credentials
    static let QB_Application_ID = "79811"
    static let QB_Auth_Key = "r3W-bxKN87mMXMk"
    static let QB_Auth_Secret = "vT26LfrFkcrGKJ8"
    static let QB_Account_Key = "B5AzGKpC2C27ByKszL7C"
    
    static let QB_ChatServiceDomain = "com.q-municate.chatservice"
    static let QB_ErrorDomaimCode = -1000
    
    
    static let Authorization = "Authorization"
    static let Basic = "Basic"
    
    static let _Id = "_Id"
    static let account_number = "account_number"
    static let account_info = "account_info"
    static let account_type = "account_type"
    static let address = "address"
    static let amount = "amount"
    static let appointment_date = "appointment_date"
    static let appointment_id = "appointment_id"
    static let auth_token = "auth_token"
    static let available_from = "available_from"
    static let available_to = "available_to"
    static let avg_rating = "avg_rating"
    static let bank_name = "bank_name"
    static let bank_statement = "bank_statement"
    static let branch = "branch"
    static let browse = "browse"
    static let certificates = "certificates"
    static let city = "city"
    static let confirm = "confirm"
    static let comment = "comment"
    static let comments_count = "comments_count"
    static let consults_count = "consults_count"
    static let country = "country"
    static let confirm_password = "confirm_password"
    static let date = "date"
    static let degree = "degree"
    static let details = "details"
    static let DeviceToken = "DeviceToken"
    static let dob = "dob"
    static let email = "email"
    static let error = "error"
    static let experience = "experience"
    static let facebook = "facebook"
    static let facebook_id = "facebook_id"
    static let file_size = "file_size"
    static let from_value = "from_value"
    static let full_name = "full_name"
    static let google = "google"
    static let google_id = "google_id"
    static let id = "id"
    static let l_id = "l_id"
    static let latitude = "latitude"
    static let lawyer = "lawyer"
    static let lawyer_id = "lawyer_id"
    static let lawyer_type = "lawyer_type"
    static let live_status = "live_status"
    static let login_type = "login_type"
    static let longitude = "longitude"
    static let mobile_no = "mobile_no"
    static let mobile_number = "mobile_number"
    static let name = "name"
    static let notification_id = "notification_id"
    static let No_record_found = "No record found"
    static let Online = "Online"
    static let Offline = "Offline"
    static let password = "password"
    static let phonecode = "phonecode"
    static let prefix_user_ = "user_"
    static let profile_pic = "profile_pic"
    static let qb_login = "login"
    static let qb_fullname = "full_name"
    static let qb_password = "qb_password"
    static let rating = "rating"
    static let response = "response"
    static let state = "state"
    static let status = "status"
    static let success = "success"
    static let time = "time"
    static let to_value = "to_value"
    static let top_rated = "top_rated"
    static let twitter = "twitter"
    static let twitter_id = "twitter_id"
    static let type = "type"
    static let user = "user"
    static let user_id = "user_id"
    static let username = "username"
    static let value = "value"
    static let view_count = "view_count"
    static let wallet_amount = "wallet_amount"
    
    
    enum AccountType: Int {
        case Guest = 0
        case User
        case Lawyer
    }
    
    enum TabItem: Int {
        case Home = 0
        case Appointment
        case Notification
        case Messages
        case Profile
    }
    
    enum SearchFilter: Int {
        case Country = 0
        case LawyerType
        case TopRated
        case Price
    }
    
    enum SearchCategory: Int {
        case NearToYou = 0
        case TopRated
        case StatusOnline
    }
    
    enum UserStatus: Int {
        case Active = 0
        case Offline
        case Invisible
    }
    
    enum CommuAction: Int {
        case Audio = 0
        case Video
        case Chat
        case SetDate
        case Hire
    }
}

enum DialogAction {
    case create
    case add
}

struct DialogsConstant {
    static let dialogsPageLimit:Int = 100
    static let segueGoToChat = "goToChat"
    static let selectOpponents = "SelectOpponents"
    static let infoSegue = "PresentInfoViewController"
}

enum MessageStatus: Int {
    case sent
    case sending
    case notSent
}

enum ChatMessageType: Int {
    case TypingNow
    case Notification
    case Incoming
    case Outgoing
}

struct ChatImage {
    static let MaxWidth: CGFloat = 200
    static let MaxHeight: CGFloat = 300
}


struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 60.0
    static let dialingTimeInterval: TimeInterval = 5.0
}

struct UsersConstant {
    static let pageSize: UInt = 50
    static let aps = "aps"
    static let alert = "alert"
    static let voipEvent = "VOIPCall"
}

