//
//  AppDelegate.swift
//  Lawyer
//
//  Created by Admin on 10/28/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import IQKeyboardManagerSwift
import FBSDKCoreKit
import QuickbloxWebRTC


@_exported import SVProgressHUD
@_exported import ObjectMapper


struct AppDelegateConstant {
    static let enableStatsReports: UInt = 1
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var mainTabVC: LawyerTabVC?
    var topBarHeight: CGFloat = 64.0
    
    var userLocation: CLLocation?
    
    var isCalling = false {
        didSet {
            if UIApplication.shared.applicationState == .background,
                isCalling == false {
                disconnect()
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        application.applicationIconBadgeNumber = 0
        
        IQKeyboardManager.shared.enable = true
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        
        // Initiate the iOS Facebook SDK
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Initialize QuickBlox
        initQB()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        application.applicationIconBadgeNumber = 0
        
        // Logging out from chat.
        ChatManager.instance.disconnect()
        
        // Logging out from chat.
        if isCalling == false {
            disconnect()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // Logging in to chat.
        AppManager.shared.registerForRemoteNotifications()
        
        ChatManager.instance.connect { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            
        }
        
        // Logging in to chat.
        if QBChat.instance.isConnected == true {
            return
        }
        connect { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            SVProgressHUD.showSuccess(withStatus: "Connected")
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        ChatManager.instance.disconnect()
        
        // Logging out from chat.
        disconnect()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let appId: String = Settings.appID!
        guard let scheme = url.scheme else {
            return false
        }
        
        if scheme.hasPrefix("fb\(appId)") && url.host == "authorize" {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        return false
    }
    
    
    //MARK: - UNUserNotification
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }

        let deviceIdentifier = identifierForVendor.uuidString
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
        }, errorBlock: { response in
            debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
//    private func registerForRemoteNotifications() {
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
//            if let error = error {
//                debugPrint("[AppDelegate] requestAuthorization error: \(error.localizedDescription)")
//                return
//            }
//            center.getNotificationSettings(completionHandler: { settings in
//                if settings.authorizationStatus != .authorized {
//                    return
//                }
//                DispatchQueue.main.async(execute: {
//                    UIApplication.shared.registerForRemoteNotifications()
//                })
//            })
//        })
//    }

    func initQB() {
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = UInt(G.QB_Application_ID)!
        QBSettings.authKey = G.QB_Auth_Key
        QBSettings.authSecret = G.QB_Auth_Secret
        QBSettings.accountKey = G.QB_Account_Key
        
        // enabling carbons for chat
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        
        QBSettings.autoReconnectEnabled = true
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)
        
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        
        QBRTCClient.initializeRTC()
    }
    
    //MARK: - Connect/Disconnect
    func connect(completion: QBChatCompletionBlock? = nil) {
        let currentUser = Profile()
        
        guard currentUser.isFull == true else {
            completion?(NSError(domain: G.QB_ChatServiceDomain,
                                code: G.QB_ErrorDomaimCode,
                                userInfo: [
                NSLocalizedDescriptionKey: "Please enter your login and username."
            ]))
            return
        }
        
        if QBChat.instance.isConnected == true {
            completion?(nil)
        }
        else {
            QBSettings.autoReconnectEnabled = true
            QBChat.instance.connect(withUserID: currentUser.ID,
                                    password: currentUser.password,
                                    completion: completion)
        }
    }
    
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        QBChat.instance.disconnect(completionBlock: completion)
    }
}


//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if UIApplication.shared.applicationState == .active {
            return
        }
        
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        guard let dialogID = userInfo["PUSH_NOTIFICATION_DIALOG_ID".localized] as? String,
            dialogID.isEmpty == false else {
                return
        }
        // calling dispatch async for push notification handling to have priority in main queue
        DispatchQueue.main.async {
            
            if let chatDialog = ChatManager.instance.storage.dialog(withID: dialogID) {
                self.openChat(chatDialog)
            } else {
                ChatManager.instance.loadDialog(withID: dialogID, completion: { (loadedDialog: QBChatDialog?) -> Void in
                    guard let dialog = loadedDialog else {
                        return
                    }
                    self.openChat(dialog)
                })
            }
        }
        completionHandler()
    }
    
    //MARK: Help
    func openChat(_ chatDialog: QBChatDialog) {
        guard let window = window,
            let navigationController = window.rootViewController as? UINavigationController else {
                return
        }
        var controllers = [UIViewController]()
        
        for controller in navigationController.viewControllers {
            controllers.append(controller)
//            if controller is DialogsViewController {
//                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
//                let chatController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
//                chatController.dialogID = chatDialog.id
//                controllers.append(chatController)
//                navigationController.setViewControllers(controllers, animated: true)
//                return
//            }
        }
    }
}
