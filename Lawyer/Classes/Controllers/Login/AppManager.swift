//
//  AppManager.swift
//  Lawyer
//
//  Created by Admin on 1/31/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import PushKit
import Quickblox
import QuickbloxWebRTC
import ObjectMapper

protocol AppManagerDelegate {
    func loginManagerDidFinishToLoginToQuickBlox(manager: AppManager)
}


class AppManager: NSObject {
    
    // singleton
    static let shared = AppManager()
    
    // tab view controller
    var mainTabVC: LawyerTabVC {
        return (UIApplication.shared.delegate as! AppDelegate).mainTabVC!
    }
    
    var countries = [Country]()
    
    
    //MARK: - Properties
    var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    var session: QBRTCSession?
    var voipRegistry: PKPushRegistry = {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        return voipRegistry
    }()
    var callUUID: UUID?
    var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    
    
    func initQBRTCClient() {
        QBRTCClient.instance().add(self)
    }
    
    func loginToQB(qbLogin: String,
                   qbPassword: String,
                   qbFullname: String,
                   completion:@escaping (_ user: QBUUser?, _ error: Error?) -> Void) {
        
        let newUser = QBUUser()
        newUser.login = qbLogin
        newUser.fullName = qbFullname
        newUser.password = qbPassword
        
//        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
//            guard let self = self else {
//                return
//            }
//
//        }, errorBlock: { [weak self] response in
//            if response.status == QBResponseStatusCode.validationFailed {
//                // The user with existent login was created earlier
////                self?.login(fullName: fullName, login: qbLogin)
//                return
//            }
//        })
        
        
        QBRequest.logIn(withUserLogin: qbLogin, password: qbPassword, successBlock: { [weak self] response, user in
            guard let self = self else {
                completion(nil, nil)
                return
            }

            user.password = qbPassword
            Profile.synchronize(user)
            Profile.update(user)

            if user.fullName != qbFullname {
                self.updateFullName(fullName: qbFullname, login: qbLogin) { (error) in
                    completion(user, nil)
                }
            }
            else {
                completion(user, nil)
            }
        }, errorBlock: { response in
            if response.status == QBResponseStatusCode.unAuthorized {
                Profile.clearProfile()
            }
            completion(nil, response.error?.error)
        })
    }
    
    func updateFullName(fullName: String,
                        login: String,
                        completion:@escaping (_ error: Error?) -> Void) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: { response, user in
            Profile.update(user)
            completion(nil)
        }, errorBlock: { respone in
            completion(respone.error?.error)
        })
    }
    
    func connectToChat(user: QBUUser,
                       completion:@escaping (_ error: Error?) -> Void) {
        QBChat.instance.connect(withUserID: user.id,
                                password: user.password!,
                                completion: { error in
                                    
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            // Clean profile
                                            Profile.clearProfile()
                                        }
                                        completion(error)
                                    }
                                    else {
                                        self.initQBRTCClient()
                                        self.registerForRemoteNotifications()
                                        self.registerForVoIPNotifications()
                                        self.updateStorageInBackground()
                                        
                                        completion(nil)
                                    }
        })
    }
    
    func connectToChat() {
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        
        QBChat.instance.connect(withUserID: profile.ID,
                                password: profile.password,
                                completion: { [weak self] error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            self.signout { (error) in
                                            }
                                        } else {
                                            debugPrint("[UsersViewController] login error response:\n \(error.localizedDescription)")
                                        }
                                    } else {
                                        //did Login action
                                        self.updateStorageInBackground()
                                    }
        })
    }
    
    func updateStorageInBackground() {
        if QBChat.instance.isConnected == true {
            ChatManager.instance.updateStorage()
        }
    }
    
    func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
            if let error = error {
                debugPrint("[AppManager] registerForRemoteNotifications error: \(error.localizedDescription)")
                return
            }
            center.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    return
                }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            })
        })
    }
    
    func registerForVoIPNotifications() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
    
    func signout(completion:@escaping (_ error: String?) -> Void) {
        if QBChat.instance.isConnected == false {
            self.logOut { (error) in
                completion(error)
            }
            return
        }
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            completion(nil)
            return
        }
        
        let uuidString = identifierForVendor.uuidString
        #if targetEnvironment(simulator)
        disconnectUser { (error) in
            completion(error)
        }
        #else
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
            if let subscriptions = subscriptions {
                for subscription in subscriptions {
                    if let subscriptionsUIUD = subscriptions.first?.deviceUDID,
                        subscriptionsUIUD == uuidString {
//                        subscriptionsUIUD == uuidString,
//                        subscription.notificationChannel == .APNSVOIP {
                        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
                            self.disconnectUser { (error) in
                                completion(error)
                            }
                        }, errorBlock: { error in
                            completion(error.error?.localizedDescription)
                        })
                        return
                    }
                }
            }
            self.disconnectUser { (error) in
                completion(error)
            }
            
            /*
            let subscriptionsUIUD = subscriptions?.first?.deviceUDID
            if subscriptionsUIUD == uuidString {
                QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
                    self.disconnectUser { (error) in
                        completion(error)
                    }
                }, errorBlock: { error in
                    completion(error.error?.localizedDescription)
                })
            }
            else {
                self.disconnectUser { (error) in
                    completion(error)
                }
            }
            */
        }) { response in
            if response.status.rawValue == 404 {
                self.disconnectUser { (error) in
                    completion(error)
                }
            }
            else {
                completion(response.error?.error?.localizedDescription)
            }
        }
        #endif
    }
    
    // MARK: - Internal Methods
    
    private func disconnectUser(completion:@escaping (_ error: String?) -> Void) {
        QBChat.instance.disconnect(completionBlock: { error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            self.logOut { (error) in
                completion(error)
            }
        })
    }
    
    private func logOut(completion:@escaping (_ error: String?) -> Void) {
        QBRequest.logOut(successBlock: { response in
            //ClearProfile
            Profile.clearProfile()
            ChatManager.instance.storage.clear()
            
            completion("Completed to logout")
        }) { response in
            debugPrint("[DialogsViewController] logOut error: \(response)")
            completion(response.error?.error?.localizedDescription)
        }
    }
    
    func updateQBUserAvatar(_ blobID: UInt, _ image: UIImage, completion:@escaping (_ uploadedBlob: QBCBlob?) -> Void) {
        
        DispatchQueue.global().async { () -> Void in
            
            let newImage = image
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            
            var resizedImage: UIImage? = newImage
            if (scaleCoeficient > 1.0) {
                let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
                
                // create smaller image
                UIGraphicsBeginImageContext(newSize)
                
                newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
            }
            
            // Sending attachment.
            DispatchQueue.main.async(execute: {
                // sendAttachmentMessage method always firstly adds message to memory storage
                guard let imageData = resizedImage?.pngData() else {
                    completion(nil)
                    return
                }

                QBRequest.blob(withID: blobID, successBlock: { (response, blob) in
                    // update blob
                    QBRequest.tUpdateFile(with: imageData, file: blob, successBlock: { (response) in
                        completion(blob)
                    }, statusBlock: { (request, status: QBRequestStatus?) in
                        if let status = status {
                            DispatchQueue.main.async {
                                let progress = CGFloat(Float(status.percentOfCompletion))
                                print("===> Uploading image (\(progress) %)")
                            }
                        }
                    }) { (response) in
                        completion(nil)
                    }
                }) { (response) in
                    // create new blob
                    QBRequest.tUploadFile(imageData, fileName: "MyAvatar", contentType: "image/png", isPublic: false, successBlock: { (response: QBResponse, uploadedBlob: QBCBlob) -> Void in
                        
                        let params = QBUpdateUserParameters()
                        params.blobID = uploadedBlob.id
                        
                        QBRequest.updateCurrentUser(params, successBlock: { (response, user) in
                            completion(uploadedBlob)
                        }) { (response) in
                            completion(nil)
                        }
                        
                    }, statusBlock: { (request : QBRequest?, status : QBRequestStatus?) -> Void in
                        if let status = status {
                            DispatchQueue.main.async {
                                let progress = CGFloat(Float(status.percentOfCompletion))
                                print("===> Uploading image (\(progress) %)")
                            }
                        }
                    }) { (response : QBResponse) -> Void in
                        completion(nil)
                    }
                }
            })
        }
    }
    
    func downloadQBUserAvatar(_ blobID: UInt, completion:@escaping (_ avatar: UIImage?) -> Void) {
        
        QBRequest.downloadFile(withID: blobID, successBlock: { (response: QBResponse, fileData: Data)  in
            guard let avatar = UIImage(data: fileData) else {
                completion(nil)
                return
            }
            
            completion(avatar)
            
        }, statusBlock: { (request: QBRequest, status: QBRequestStatus?) in
            guard let status = status else {
                return
            }
            
            let progress = CGFloat(status.percentOfCompletion)
            print("===> Downloading image (\(blobID)) (\(progress) %)")
            
        }, errorBlock: { (response: QBResponse) in
            completion(nil)
        })
    }
    
    func getCountries(completion:@escaping (_ countries: [Country]) -> Void) {
        if countries.count > 0 {
            completion(countries)
        }
        else {
            AppWebClient.GetCountries { (json) in
                guard let response = json,
                    response[G.status].string!.lowercased() == G.success,
                    let jsonCountries = response[G.response].array else {
                    completion(self.countries)
                    return;
                }
                
                self.countries = [Country]()
                for info in jsonCountries {
                    let country = Mapper<Country>().map(JSONString: info.rawString()!)
                    self.countries.append(country!)
                }
                completion(self.countries)
            }
        }
    }
    
    // MARK: - Internal Methods
    private func hasConnectivity() -> Bool {
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            mainTabVC.getTopVC()?.showAlert(msg: "CheckInternet".localized, handler: { (action) in
                self.mainTabVC.dismissCallVC()
            })
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall")
                }
            }
            return false
        }
        return true
    }
    
    func endCall() {
        CallKitManager.instance.endCall(with: callUUID) {
            debugPrint("[AppManager] endCall")
            self.mainTabVC.dismissCallVC()
        }
    }
    
    func call(with conferenceType: QBRTCConferenceType, qbUser: QBUUser?, lawyerzInfo: [String: Any]? = nil) {
        if session != nil {
            return
        }
        
        if hasConnectivity() {
            CallPermissions.check(with: conferenceType) { granted in
                if granted {
                    let opponentsIDs = self.dataSource.ids(forUsers: self.dataSource.selectedUsers)
                    //Create new session
                    let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: conferenceType)
                    if session.id.isEmpty == false {
                        self.session = session
                        let uuid = UUID()
                        self.callUUID = uuid
                        
                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        if let callVC = (conferenceType == .audio ? storyboard.instantiateViewController(withIdentifier: "AudioCallVC") as? AudioCallVC : storyboard.instantiateViewController(withIdentifier: "VideoCallVC") as? VideoCallVC) {
                            callVC.session = self.session
//                            callVC.usersDataSource = self.dataSource
                            callVC.callUUID = uuid
                            callVC.remoteUser = qbUser
                            callVC.lawyerzInfo = lawyerzInfo
                            
                            callVC.isPresented = true
                            callVC.modalPresentationStyle = .fullScreen
                            callVC.modalTransitionStyle = .crossDissolve
                            self.mainTabVC.getTopVC()!.present(callVC , animated: false)
//                            self.mainTabVC.getTopVC()?.navigationController?.pushViewController(callVC, animated: true)
                        }
                        
                        let profile = Profile()
                        guard profile.isFull == true else {
                            return
                        }
                        let opponentName = profile.fullName.isEmpty == false ? profile.fullName : "Unknown user"
                        let payload = ["message": "\(opponentName) is calling you.",
                            "ios_voip": "1", UsersConstant.voipEvent: "1"]
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        event.usersIDs = arrayUserIDs.joined(separator: ",")
                        event.type = QBMEventType.oneShot
                        event.message = message
                        QBRequest.createEvent(event, successBlock: { response, events in
                            debugPrint("[AppManager] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[AppManager] Send voip push - Error")
                        })
                    }
                    else {
                        self.mainTabVC.getTopVC()?.showAlert(msg: "Error_ShouldLogin".localized)
                    }
                }
            }
        }
    }
}


extension AppManager: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = pushCredentials.token
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("[UsersViewController] Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[UsersViewController] Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[UsersViewController] Unregister Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType) {
        if payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            let application = UIApplication.shared
            if application.applicationState == .background && backgroundTask == .invalid {
                backgroundTask = application.beginBackgroundTask(expirationHandler: {
                    application.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = UIBackgroundTaskIdentifier.invalid
                })
            }
            if QBChat.instance.isConnected == false {
                connectToChat()
            }
        }
    }
}


// MARK: - QBRTCClientDelegate

extension AppManager: QBRTCClientDelegate {
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false && self.session?.id == session.id && self.session?.initiatorID == userID {
            endCall()
            prepareCloseCall()
        }
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        
        self.session = session
        let uuid = UUID()
        callUUID = uuid
        var opponentIDs = [session.initiatorID]
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        for userID in session.opponentsIDs {
            if userID.uintValue != profile.ID {
                opponentIDs.append(userID)
            }
        }
        
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [NSNumber]()
        for userID in opponentIDs {
            
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID)
            }
        }
        
        if newUsers.isEmpty == false {
            let loadGroup = DispatchGroup()
            for userID in newUsers {
                loadGroup.enter()
                dataSource.loadUser(userID.uintValue) { (user) in
                    if let user = user {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    } else {
                        opponentNames.append("\(userID)")
                    }
                    loadGroup.leave()
                }
            }
            loadGroup.notify(queue: DispatchQueue.main) {
                callerName = opponentNames.joined(separator: ", ")
                self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: uuid)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: uuid)
        }
    }
    
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs, outCallerName: outCallerName, session: session, uuid: uuid, onAcceptAction: { [weak self] in
                guard let self = self else {
                    return
                }
                
                print("session.initiatorID = \(session.initiatorID) : session.currentUserID = \(session.currentUserID)")

                let conferenceType = session.conferenceType
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                if let callVC = (conferenceType == .audio ? storyboard.instantiateViewController(withIdentifier: "AudioCallVC") as? AudioCallVC : storyboard.instantiateViewController(withIdentifier: "VideoCallVC") as? VideoCallVC) {
                    callVC.session = session
                    callVC.callUUID = self.callUUID
                    
                    callVC.isPresented = true
                    callVC.modalPresentationStyle = .fullScreen
                    callVC.modalTransitionStyle = .crossDissolve
                    self.mainTabVC.getTopVC()!.present(callVC , animated: false)
                    
//                    self.mainTabVC.getTopVC()?.navigationController?.pushViewController(callVC, animated: true)
                }
                
            }, completion: { (end) in
                debugPrint("[AppManager] endCall")
            })
        } else {
            
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
//            if self.navViewController.presentingViewController?.presentedViewController == self.navViewController {
//                self.navViewController.view.isUserInteractionEnabled = false
//                self.navViewController.dismiss(animated: false)
//            }

            self.mainTabVC.dismissCallVC()
            
            endCall()
            
            prepareCloseCall()
        }
    }
    
    private func prepareCloseCall() {
        self.callUUID = nil
        self.session = nil
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }
    }
}
