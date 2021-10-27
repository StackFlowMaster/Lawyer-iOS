//
//  AppRequest.swift
//  Lawyer
//
//  Created by Admin on 12/25/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public enum AppRequest: URLRequestConvertible {
    enum K {
        static let baseURL = ""
    }
    
    case Login(email: String, password: String, latitude: String, longitude: String)
    
    // APIs for Lawyer
    case RegisterLawyer(params: [String: Any])
    case LoginLawyer(email: String, password: String, latitude: String, longitude: String)
    case ForgotPasswordLawyer(email: String)
    case GetLawyerProfile
    case EditLawyerProfile(params: [String: Any], files: [UIImage])
    case EditLawyerLocation(latitude: String, longitude: String)
    case GetAvailableTime(date: String, lawyerId: String)
    case EditAvailTime(availableFrom: String, availableTo: String)
    case GetLawyersBankInfo
    case AddLawyerBankInformation(fullName: String, bankName: String, accountNumber: String, accountType: String, branch: String, amount: String)
    case GetLawyerNotification
    case GetLawyerAllAppointment
    
    // APIs for User
    case RegisterUser(params: [String: Any])
    case LoginUser(email: String, password: String, latitude: String, longitude: String)
    case ForgotPasswordUser(email: String)
    case GetUserProfile
    case EditUserProfile(fullName: String, city: String, state: String, country: String)
    case EditUserLocation(latitude: String, longitude: String)
    case GetUserNotification
    case GetUserAllAppointment
    
    // Other apis
    case GetLawyersType
    case AddAppointment(lawyerId: String, appointmentDate: String, time: String, mobileNo: String)
    case GetAppointment(lawyerId: String, appointmentDate: String, time: String, mobileNo: String)
    case Makepayment
    case GetCharges
    case GetCountries
    case GetSettings
    
    case SocialLawyerLogin(fullName: String, email: String, loginType: String, fbUserId: String, googleUserId: String, twitterUserId: String)
    case SocialUserLogin(fullName: String, email: String, loginType: String, fbUserId: String, googleUserId: String, twitterUserId: String)
    
    case GetAllDetailsLawyer(lawyerId: String)
    case GetAllDetailsUser(userId: String)
    case AddRating(lawyerId: String, rating: String, comment: String)
    case GetNearLawyers(latitude: String, longitude: String)
    case GetTopRatedLawyers
    case GetOnlineLawyer
    case AddViews(lawyerId: String)
    case GetLawyerRating
    case GetLawyerMonthlyProgress
    
    case UpdateLawyerStatus(liveStatus: String)
    case UpdateUserStatus(liveStatus: String)
    
    case GetUserAppointment(appointmentDate: String)
    case GetLawyerAppointment(appointmentDate: String)
    
    case Search_lawyers(name: String, country: String, lawyerType: String, fromValue: String, toValue: String, topRated: String)
    case CashOut(fullName: String, bankName: String, accountNumber: String, accountType: String, branch: String, amount: String)
    
    case ReadLawyerNotification(notificationId: String)
    case ReadUserNotification(notificationId: String)
    
    
    var method: HTTPMethod {
        switch self {
        case .GetLawyerProfile:
            return .get
        case .GetLawyersBankInfo:
            return .get
        case .GetLawyerNotification:
            return .get
        case .GetLawyerAllAppointment:
            return .get
            
        case .GetUserProfile:
            return .get
        case .GetUserNotification:
            return .get
        case .GetUserAllAppointment:
            return .get

        case .GetLawyersType:
            return .get
        case .GetCharges:
            return .get
        case .GetCountries:
            return .get
        case .GetSettings:
            return .get
            
        case .GetAllDetailsLawyer:
            return .get
        case .GetAllDetailsUser:
            return .get
        case .GetTopRatedLawyers:
            return .get
        case .GetOnlineLawyer:
            return .get
        case .GetLawyerRating:
            return .get
        case .GetLawyerMonthlyProgress:
            return .get
            
        case .ReadLawyerNotification:
            return .get
        case .ReadUserNotification:
            return .get
        default:
            return .post
        }
    }

    var encoder: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
    
    var path: String {
        switch self {
        case .Login:
            return "Login"
            
        case .RegisterLawyer:
            return "RegisterLawyer"
        case .LoginLawyer:
            return "LoginLawyer"
        case .ForgotPasswordLawyer:
            return "ForgotPasswordLawyer"
        case .GetLawyerProfile:
            return "GetLawyerProfile"
        case .EditLawyerProfile:
            return "EditLawyerProfile"
        case .EditLawyerLocation:
            return "EditLawyerLocation"
        case .GetAvailableTime:
            return "GetAvailableTime"
        case .EditAvailTime:
            return "EditAvailTime"
        case .GetLawyersBankInfo:
            return "GetLawyersBankInfo"
        case .AddLawyerBankInformation:
            return "AddLawyerBankInformation"
        case .GetLawyerNotification:
            return "GetLawyerNotification"
        case .GetLawyerAllAppointment:
            return "GetLawyerAllAppointment"
            
        case .RegisterUser:
            return "RegisterUser"
        case .LoginUser:
            return "LoginUser"
        case .ForgotPasswordUser:
            return "ForgotPasswordUser"
        case .GetUserProfile:
            return "GetUserProfile"
        case .EditUserProfile:
            return "EditUserProfile"
        case .EditUserLocation:
            return "EditUserLocation"
        case .GetUserNotification:
            return "GetUserNotification"
        case .GetUserAllAppointment:
            return "GetUserAllAppointment"

        case .GetLawyersType:
            return "GetLawyersType"
        case .AddAppointment:
            return "AddAppointment"
        case .GetAppointment:
            return "GetAppointment"
        case .Makepayment:
            return "Makepayment"
        case .GetCharges:
            return "GetCharges"
        case .GetCountries:
            return "GetCountries"
        case .GetSettings:
            return "GetSettings"

        case .SocialLawyerLogin:
            return "SocialLawyerLogin"
        case .SocialUserLogin:
            return "SocialUserLogin"
            
        case .GetAllDetailsLawyer(let lawyerId):
            return "GetAllDetailsLawyer/\(lawyerId)"
        case .GetAllDetailsUser(let userId):
            return "GetAllDetailsUser/\(userId)"
        case .AddRating:
            return "AddRating"
        case .GetNearLawyers:
            return "GetNearLawyers"
        case .GetTopRatedLawyers:
            return "GetTopRatedLawyers"
        case .GetOnlineLawyer:
            return "GetOnlineLawyer"
        case .AddViews:
            return "AddViews"
        case .GetLawyerRating:
            return "GetLawyerRating"
        case .GetLawyerMonthlyProgress:
            return "GetLawyerMonthlyProgress"
            
        case .UpdateLawyerStatus:
            return "UpdateLawyerStatus"
        case .UpdateUserStatus:
            return "UpdateUserStatus"
            
        case .GetUserAppointment:
            return "GetUserAppointment"
        case .GetLawyerAppointment:
            return "GetLawyerAppointment"
            
        case .Search_lawyers:
            return "Search_lawyers"
        case .CashOut:
            return "CashOut"
            
        case .ReadLawyerNotification(let notificationId):
            return "ReadLawyerNotification/\(notificationId)"
        case .ReadUserNotification(let notificationId):
            return "ReadUserNotification/\(notificationId)"
        }
    }
    
    var isInternalApi: Bool {
        switch self {
        case .Login:
            return false
            
        case .RegisterLawyer:
            return false
        case .LoginLawyer:
            return false
        case .ForgotPasswordLawyer:
            return false
            
        case .RegisterUser:
            return false
        case .LoginUser:
            return false
        case .ForgotPasswordUser:
            return false

        case .GetLawyersType:
            return false
        case .GetCharges:
            return false
        case .GetCountries:
            return false
        case .GetSettings:
            return false

        case .SocialLawyerLogin:
            return false
        case .SocialUserLogin:
            return false
            
        case .GetAllDetailsLawyer:
            return false
        case .GetAllDetailsUser:
            return false
        case .GetNearLawyers:
            return false
        case .GetTopRatedLawyers:
            return false
        case .GetOnlineLawyer:
            return false
        case .GetLawyerRating:
            return false
        case .Search_lawyers:
            return false
        default:
            return true
        }
    }
    
    var defaultParams: [String: Any] {
        switch self {
        case .LoginLawyer:
            return [ : ]
        default:
            return [
//                "MaxCount" : 50,
//                "ReturnData" : false
                :
            ]
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .Login(let email, let password, let latitude, let longitude):
            return [
                G.email: email,
                G.password: password,
                G.latitude: latitude,
                G.longitude: longitude
            ]
            
        case .RegisterLawyer(let params):
            return params
        case .LoginLawyer(let email, let password, let latitude, let longitude):
            return [
                G.email: email,
                G.password: password,
                G.latitude: latitude,
                G.longitude: longitude
            ]
        case .ForgotPasswordLawyer(let email):
            return [
                G.email: email
            ]
        case .GetLawyerProfile:
            return [:]
        case .EditLawyerProfile(let params, _):
            return params
        case .EditLawyerLocation(let latitude, let longitude):
            return [
                G.latitude: latitude,
                G.longitude: longitude
            ]
        case .GetAvailableTime(let date, let lawyerId):
            return [
                G.date: date,
                G.lawyer_id: lawyerId
            ]
        case .EditAvailTime(let availableFrom, let availableTo):
            return [
                G.available_from: availableFrom,
                G.available_to: availableTo
            ]
        case .GetLawyersBankInfo:
            return [:]
        case .AddLawyerBankInformation(let fullName, let bankName, let accountNumber, let accountType, let branch, let amount):
            return [
                G.full_name: fullName,
                G.bank_name: bankName,
                G.account_number: accountNumber,
                G.account_type: accountType,
                G.branch: branch,
                G.amount: amount
            ]
        case .GetLawyerNotification:
            return [:]
        case .GetLawyerAllAppointment:
            return [:]
            
            
        case .RegisterUser(let params):
            return params
        case .LoginUser(let email, let password, let latitude, let longitude):
            return [
                G.email: email,
                G.password: password,
                G.latitude: latitude,
                G.longitude: longitude
            ]
        case .ForgotPasswordUser(let email):
            return [
                G.email: email
            ]
        case .GetUserProfile:
            return [:]
        case .EditUserProfile(let fullName, let city, let state, let country):
            return [
                G.full_name: fullName,
                G.city: city,
                G.state: state,
                G.country: country
            ]
        case .EditUserLocation(let latitude, let longitude):
            return [
                G.latitude: latitude,
                G.longitude: longitude
            ]
        case .GetUserNotification:
            return [:]
        case .GetUserAllAppointment:
            return [:]
            

        case .GetLawyersType:
            return [:]
        case .AddAppointment(let lawyerId, let appointmentDate, let time, let mobileNo):
            return [
                G.lawyer_id: lawyerId,
                G.appointment_date: appointmentDate,
                G.time: time,
                G.mobile_no: mobileNo
            ]
        case .GetAppointment(let lawyerId, let appointmentDate, let time, let mobileNo):
            return [
                G.lawyer_id: lawyerId,
                G.appointment_date: appointmentDate,
                G.time: time,
                G.mobile_no: mobileNo
            ]
        case .Makepayment:
            return [:]
        case .GetCharges:
            return [:]
        case .GetCountries:
            return [:]
        case .GetSettings:
            return [:]

        case .SocialLawyerLogin(let fullName, let email, let loginType, let fbUserId, let googleUserId, let twitterUserId):
            return [
                G.full_name: fullName,
                G.email: email,
                G.login_type: loginType,
                G.facebook_id: fbUserId,
                G.google_id: googleUserId,
                G.twitter_id: twitterUserId
            ]
        case .SocialUserLogin(let fullName, let email, let loginType, let fbUserId, let googleUserId, let twitterUserId):
            return [
                G.full_name: fullName,
                G.email: email,
                G.login_type: loginType,
                G.facebook_id: fbUserId,
                G.google_id: googleUserId,
                G.twitter_id: twitterUserId
            ]
            
        case .GetAllDetailsLawyer:
            return [:]
        case .GetAllDetailsUser:
            return [:]
        case .AddRating(let lawyerId, let rating, let comment):
            return [
                G.lawyer_id: lawyerId,
                G.rating: rating,
                G.comment: comment
            ]
        case .GetNearLawyers(let latitude, let longitude):
            return [
                G.latitude: latitude,
                G.longitude: longitude
            ]
        case .GetTopRatedLawyers:
            return [:]
        case .GetOnlineLawyer:
            return [:]
        case .AddViews(let lawyerId):
            return [
                G.lawyer_id: lawyerId
            ]
        case .GetLawyerRating:
            return [:]
        case .GetLawyerMonthlyProgress:
            return [:]
            
        case .UpdateLawyerStatus(let liveStatus):
            return [
                G.live_status: liveStatus
            ]
        case .UpdateUserStatus(let liveStatus):
            return [
                G.live_status: liveStatus
            ]
            
        case .GetUserAppointment(let appointmentDate):
            return [
                G.appointment_date: appointmentDate
            ]
        case .GetLawyerAppointment(let appointmentDate):
            return [
                G.appointment_date: appointmentDate
            ]
            
        case .Search_lawyers(let name, let country, let lawyerType, let fromValue, let toValue, let topRated):
            return [
                G.name: name,
                G.country: country,
                G.lawyer_type: lawyerType,
                G.from_value: fromValue,
                G.to_value: toValue,
                G.top_rated: topRated
            ]
        case .CashOut(let fullName, let bankName, let accountNumber, let accountType, let branch, let amount):
            return [
                G.full_name: fullName,
                G.bank_name: bankName,
                G.account_number: accountNumber,
                G.account_type: accountType,
                G.branch: branch,
                G.amount: amount
            ]
            
        case .ReadLawyerNotification:
            return [:]
        case .ReadUserNotification:
            return [:]
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try K.baseURL.asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))

        let authToken = isInternalApi ? AppShared.getAuthToken() : G.HTTP_AUTH_PASSWORD
        let credentialData = "\(G.HTTP_AUTH_USERNAME):\(authToken)".data(using: .utf8)
        let base64Credentials = credentialData!.base64EncodedString(options: [])
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.httpMethod = method.rawValue
        
        // append default params
        let params = parameters.merging(defaultParams) { (key, _) in key }
        
//        let encoder: ParameterEncoding = (method == .get) ? URLEncoding.default : JSONEncoding.default
        
        return try encoder.encode(request, with: params)
    }
    
    public func log(_ response:Any) {
        print("------------------------------------------------")
        print(
            "API:", "\(K.baseURL)/\(self.path)",
            "API type:", isInternalApi ? "Internal" : "External",
            "METHOD:", "\(method.rawValue)",
            "STATUS:", (response is JSON) ? "SUCCESS" : "FAILED",
            "PARAMS:", "\(self.parameters)\n\(self.defaultParams)",
            "RESULT:", "\(response)",
            separator: "\n")
        print("------------------------------------------------")
    }
}
