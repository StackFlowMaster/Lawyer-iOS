//
//  AppSyncManager.swift
//  Lawyer
//
//  Created by Admin on 12/25/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import SwiftyJSON

class AppSyncManager {
    private static let syncInterval = TimeInterval(15 * 60)
    private var timer: Timer?

    private init() {
        
    }
    
    func run() {
        // background sync process
        timer = Timer.scheduledTimer(timeInterval: AppSyncManager.syncInterval, target: self, selector: #selector(syncAll), userInfo: nil, repeats: true)
    }
    
    @objc private func syncAll() {
        let completion : (Bool) -> Void = {_ in
            // do nothing
        }
//        VTSyncManager.syncAll(completion)
    }
    
    // singleton
    static let shared = AppSyncManager()
    
    
    
//    // get divisions (departments)
//    class func getDepartments (_ completion:@escaping (_ finished:Bool) -> Void) {
//        AppWebClient.divisions { (response) in
//            guard let json = response, json["IsOk"].intValue == 1 else {
//                completion(false)
//                return
//            }
//
//            guard let departments = json["Departments"].array else {
//                completion(false)
//                return
//            }
//
//            VTShared.shared.departments.removeAll()
//            for d in departments {
//                let department = Department(d)
//                department.save()
//            }
//            VTShared.shared.departments = Department.getDepartmentsWithCompanyId(User.authed.companyId)
//            completion(true)
//
////            let inBatch = contacts.count
////            if inBatch < 50 {
////                // finish
////                VTShared.shared.contacts.sort(by: { $0.firstName < $1.firstName })
////                completion(true)
////                return
////            } else {
////                // get session and do recursive call
////                let sessionId = json["SessionId"].stringValue
////                if !sessionId.isEmpty {
////                    VTSyncManager.getContacts(sessionId: sessionId, completion: completion)
////                } else {
////                    // not perfect, but session is expired
////                    completion(true)
////                }
////            }
//        }
//    }
//    class func postCheckins(_ completion:@escaping (_ finished:Bool) -> Void) {
//        let checkins = Department.getDepartmentsWithCompanyId(User.authed.companyId)
//
//        if checkins.count > 0 {
//            var postCheckins:[Any] = []
//            for d in checkins {
//                postCheckins.append(d.postDictionary())
//            }
//
//            AppWebClient.checkin(checkins: postCheckins) { (success) in
//                if success {
//                    Department.markUndirtyAll()
//                }
//
//                completion(success)
//            }
//        }
//    }
//
//    class func syncAll(_ completion:@escaping (_ finished:Bool) -> Void) {
//        // step 1: send all dirty messages to server
//        let dirties = Notification.getDirtyNotifications()
//        if dirties.count > 0 {
//            var dirtyDictionarys:[Any] = []
//            for d in dirties {
//                dirtyDictionarys.append(d.toDictionary())
//            }
//
//            AppWebClient.syncDirty(notifications: dirtyDictionarys) { (success) in
//                if success {
//                    // step 2: mark dirty messages on db as isDirty=0
//                    Notification.markSentAll()
//                }
//
//                // step 3: receive all messages from server
//                VTSyncManager.getNotifications(sessionId: "") { (finished) in
//                    completion(finished)
//                }
//            }
//            return
//        }
//
//        // step 3: receive all messages from server
//        VTSyncManager.getNotifications(sessionId: "") { (finished) in
//            completion(finished)
//        }
//    }
    
}
