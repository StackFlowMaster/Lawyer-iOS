//
//  AppWebClient.swift
//  Lawyer
//
//  Created by Admin on 12/25/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

class AppWebClient {
    private var defaultManager: Alamofire.Session!
    
    static let shared = AppWebClient()
    
    private init() {
        defaultManager = Alamofire.Session.default
    }
    
    @discardableResult
    private static func performRequest(request:AppRequest, completion:@escaping (JSON?)->Void) -> DataRequest {
        return AppWebClient.shared.defaultManager.request(request)
            .responseJSON(completionHandler: { (response) in

                switch response.result {
                case .success(_):
                    break
                case .failure(_):
                    break
                }
                
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    request.log(json)
                    completion(json)
                    break
                case .failure(let error):
                    request.log(String(describing: error))
                    completion(nil)
                    return
                }
            })
    }
    
    
    // MARK: - Common apis
    static func Login(email: String, password: String, latitude: String, longitude: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.Login(email: email, password: password, latitude: latitude, longitude: longitude)) { (response) in
            completion(response)
        }
    }
    
    
    // MARK: -  Lawyer apis
    static func RegisterLawyer(params: [String: Any], completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.RegisterLawyer(params: params)) { (response) in
            completion(response)
        }
    }
    
    static func LoginLawyer(email: String, password: String, latitude: String, longitude: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.LoginLawyer(email: email, password: password, latitude: latitude, longitude: longitude)) { (response) in
            completion(response)
        }
    }
    
    static func ForgotPasswordLawyer(email: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.ForgotPasswordLawyer(email: email)) { (response) in
            completion(response)
        }
    }
    
    static func GetLawyerProfile(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyerProfile) { (response) in
            completion(response)
        }
    }
    
    static func EditLawyerProfile(params: [String: Any], files: [UIImage], completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.EditLawyerProfile(params: params, files: files)) { (response) in
            completion(response)
        }
    }
    
    static func EditLawyerLocation(latitude: String, longitude: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.EditLawyerLocation(latitude: latitude, longitude: longitude)) { (response) in
            completion(response)
        }
    }
    
    static func GetAvailableTime(date: String, lawyerId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetAvailableTime(date: date, lawyerId: lawyerId)) { (response) in
            completion(response)
        }
    }
    
    static func EditAvailTime(availableFrom: String, availableTo: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.EditAvailTime(availableFrom: availableFrom, availableTo: availableTo)) { (response) in
            completion(response)
        }
    }
    
    static func GetLawyersBankInfo(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyersBankInfo) { (response) in
            completion(response)
        }
    }
    
    static func AddLawyerBankInformation(fullName: String, bankName: String, accountNumber: String, accountType: String, branch: String, amount: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.AddLawyerBankInformation(fullName: fullName, bankName: bankName, accountNumber: accountNumber, accountType: accountType, branch: branch, amount: amount)) { (response) in
            completion(response)
        }
    }
    
    static func GetLawyerNotification(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyerNotification) { (response) in
            completion(response)
        }
    }
    
    static func GetLawyerAllAppointment(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyerAllAppointment) { (response) in
            completion(response)
        }
    }
    
    
    
    // MARK: -  User apis
    
    static func RegisterUser(params: [String: Any], completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.RegisterUser(params: params)) { (response) in
            completion(response)
        }
    }
    
    static func LoginUser(email: String, password: String, latitude: String, longitude: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.LoginUser(email: email, password: password, latitude: latitude, longitude: longitude)) { (response) in
            completion(response)
        }
    }
    
    static func ForgotPasswordUser(email: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.ForgotPasswordUser(email: email)) { (response) in
            completion(response)
        }
    }
    
    static func GetUserProfile(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetUserProfile) { (response) in
            completion(response)
        }
    }
    
    static func EditUserProfile(fullName: String, city: String, state: String, country: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.EditUserProfile(fullName: fullName, city: city, state: state, country: country)) { (response) in
            completion(response)
        }
    }
    
    static func EditUserLocation(latitude: String, longitude: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.EditUserLocation(latitude: latitude, longitude: longitude)) { (response) in
            completion(response)
        }
    }
    
    static func GetUserNotification(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetUserNotification) { (response) in
            completion(response)
        }
    }
    
    static func GetUserAllAppointment(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetUserAllAppointment) { (response) in
            completion(response)
        }
    }
    
    
    // MARK: -  Other apis
    
    static func GetLawyersType(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyersType) { (response) in
            completion(response)
        }
    }
    
    static func AddAppointment(lawyerId: String, appointmentDate: String, time: String, mobileNo: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.AddAppointment(lawyerId: lawyerId, appointmentDate: appointmentDate, time: time, mobileNo: mobileNo)) { (response) in
            completion(response)
        }
    }
    
    static func GetAppointment(lawyerId: String, appointmentDate: String, time: String, mobileNo: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetAppointment(lawyerId: lawyerId, appointmentDate: appointmentDate, time: time, mobileNo: mobileNo)) { (response) in
            completion(response)
        }
    }
    
    static func Makepayment(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.Makepayment) { (response) in
            completion(response)
        }
    }
    
    static func GetCharges(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetCharges) { (response) in
            completion(response)
        }
    }
    
    static func GetCountries(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetCountries) { (response) in
            completion(response)
        }
    }
    
    static func GetSettings(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetSettings) { (response) in
            completion(response)
        }
    }
    
    
    static func SocialLawyerLogin(fullName: String, email: String, loginType: String, fbUserId: String, googleUserId: String, twitterUserId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.SocialLawyerLogin(fullName: fullName, email: email, loginType: loginType, fbUserId: fbUserId, googleUserId: googleUserId, twitterUserId: twitterUserId)) { (response) in
            completion(response)
        }
    }
    
    static func SocialUserLogin(fullName: String, email: String, loginType: String, fbUserId: String, googleUserId: String, twitterUserId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.SocialUserLogin(fullName: fullName, email: email, loginType: loginType, fbUserId: fbUserId, googleUserId: googleUserId, twitterUserId: twitterUserId)) { (response) in
            completion(response)
        }
    }
    
    static func GetAllDetailsLawyer(lawyerId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetAllDetailsLawyer(lawyerId: lawyerId)) { (response) in
            completion(response)
        }
    }
    
    static func GetAllDetailsUser(userId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetAllDetailsUser(userId: userId)) { (response) in
            completion(response)
        }
    }
    
    static func AddRating(lawyerId: String, rating: String, comment: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.AddRating(lawyerId: lawyerId, rating: rating, comment: comment)) { (response) in
            completion(response)
        }
    }
    
    static func GetNearLawyers(latitude: String, longitude: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetNearLawyers(latitude: latitude, longitude: longitude)) { (response) in
            completion(response)
        }
    }
    
    static func GetTopRatedLawyers(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetTopRatedLawyers) { (response) in
            completion(response)
        }
    }
    
    static func GetOnlineLawyer(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetOnlineLawyer) { (response) in
            completion(response)
        }
    }
    
    static func AddViews(lawyerId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.AddViews(lawyerId: lawyerId)) { (response) in
            completion(response)
        }
    }
    
    static func GetLawyerRating(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyerRating) { (response) in
            completion(response)
        }
    }
    
    static func GetLawyerMonthlyProgress(completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyerMonthlyProgress) { (response) in
            completion(response)
        }
    }
    
    static func UpdateLawyerStatus(liveStatus: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.UpdateLawyerStatus(liveStatus: liveStatus)) { (response) in
            completion(response)
        }
    }
    
    static func UpdateUserStatus(liveStatus: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.UpdateUserStatus(liveStatus: liveStatus)) { (response) in
            completion(response)
        }
    }
    
    static func GetUserAppointment(appointmentDate: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetUserAppointment(appointmentDate: appointmentDate)) { (response) in
            completion(response)
        }
    }
    
    static func GetLawyerAppointment(appointmentDate: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.GetLawyerAppointment(appointmentDate: appointmentDate)) { (response) in
            completion(response)
        }
    }
    
    static func Search_lawyers(name: String, country: String, lawyerType: String, fromValue: String, toValue: String, topRated: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.Search_lawyers(name: name, country: country, lawyerType: lawyerType, fromValue: fromValue, toValue: toValue, topRated: topRated)) { (response) in
            completion(response)
        }
    }
    
    static func CashOut(fullName: String, bankName: String, accountNumber: String, accountType: String, branch: String, amount: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.CashOut(fullName: fullName, bankName: bankName, accountNumber: accountNumber, accountType: accountType, branch: branch, amount: amount)) { (response) in
            completion(response)
        }
    }
    
    
    static func ReadLawyerNotification(notificationId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.ReadLawyerNotification(notificationId: notificationId)) { (response) in
            completion(response)
        }
    }
    
    static func ReadUserNotification(notificationId: String, completion:@escaping (_ jsonResponse:JSON?)->Void) {
        performRequest(request: AppRequest.ReadUserNotification(notificationId: notificationId)) { (response) in
            completion(response)
        }
    }
    
//    static func syncDirty(notifications: [Any], completion:@escaping (_ success:Bool)->Void) {
//        performRequest(request: AppRequest.syncDirty(notifications: notifications)) { (response) in
//            guard let json = response else {
//                completion(false)
//                return
//            }
//            completion(json["IsOk"].intValue == 1)
//        }
//    }
    
}
