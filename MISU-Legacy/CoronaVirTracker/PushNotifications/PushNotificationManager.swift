//
//  PushNotificationManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotificationManager {
    static let shared: PushNotificationManager = PushNotificationManager()
    private init() {
        ChatsSinglManager.shared.appIconDelegate = self
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Notification granted: \(granted)")
            print("Notification error: \(String(describing: error))")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("NotificationSettings: \(settings)")
            print("NotificationSettings status: \(settings.authorizationStatus)")
            
            switch settings.authorizationStatus {
            case .notDetermined:
                print("notDetermined")
                self.registerForPushNotifications()
            case .denied:
                // ask to go to settins
                //DispatchQueue.main.async { self.goToSettings() }
                print("denied")
            case .authorized:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("authorized")
            case .provisional:
                print("Provisional")
            default:
                return
            }
        }
    }
    
    func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
}



// MARK: - AppDelegate funcs
extension PushNotificationManager {
    func userNotificationCenterwillPresent(notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        print("userNotificationCenter willPresent: \(userInfo)")
        //ChatsSinglManager.shared.appIconDelegate?.gotNewMessage(1)
        //self.appIconDelegate?.gotNewMessage(unreded.count)
        ChatsSinglManager.shared.gotPushNotification(PushNotificationModel(decode: userInfo))
    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], navController: UINavigationController? = nil) {
        print("Did recive remote: \(userInfo)")
        ChatsSinglManager.shared.openPushNotification(PushNotificationModel(decode: userInfo), navController: navController)
    }
    
    func didFinishLaunchingWithOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let notificationOption = launchOptions?[.remoteNotification]
        print("NotifOp: \(String(describing: notificationOption))")
        // parse notification
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        PushNotificationReqManager.shared.setDevice(deviceId: token) { (success, error) in
            print("Push Notif: setDevice success: \(String(describing: success))")
            print("Push Notif: setDevice error: \(String(describing: error))")
        }
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("Failed to register: \(error)")
    }
}



// MARK: - Chats Manager Delegate
extension PushNotificationManager: AppIconNewMessagesDelegate {
    func gotNewMessage(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
}
/*
 
[
AnyHashable("sender"): 36,
AnyHashable("text"): 123,
AnyHashable("id"): 290,
AnyHashable("aps"): {
    alert =     {
        body = 123;
        title = "\U0421\U043e\U0444\U0456\U044f \U0421\U043e\U0444\U0443\U0448\U043a\U0430";
    };
    sound = default;
},
AnyHashable("chat_id"): 20
]
 
*/
