//
//  AppDelegate.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/12/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    // Wee Watch-Test
    // Sofi Test
    // Drugs
    // Supp
    
    /// Example of description
    ///        qweqwe
    /// - Parameters:
    ///   - a: The first value.
    ///   - b: The second value.
    ///   - c: The third value.
    /// - Returns: The average of the three values.
    /// - Discusion
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        print("blablabla")
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        /// DEBUG
        /*
        do {
            try WatchFakeVPNManager().manager?.connection.startVPNTunnel(options: [
                NEVPNConnectionStartOptionUsername: "kean",
                NEVPNConnectionStartOptionPassword: "password"
            ] as [String : NSObject])
        } catch {
            print("### Failed to start VPN tunnel message: \(error.localizedDescription)")
        }
        */
        
        //application.setMinimumBackgroundFetchInterval(3)
        //print("### - \(String(describing: UserDefaultsUtils.getInt(key: "Test")))")
        //UserDefaultsUtils.save(value: 0, key: "Test")
        //_ = KeychainUtils.saveCurrentUserToken("2c7b853f459d2fc56d730130d851b01a861848c8") // Doctor House
        //_ = KeychainUtils.saveCurrentUserToken("5507d86c0efb748802bdd6038d1c4aa542e5180e") // Sofi
        //_ = KeychainUtils.saveCurrentUserToken("9f64319923231794b7941c8e7f2ab6ed15752f2f") // Dmitriy
        //_ = KeychainUtils.saveCurrentUserToken("2e902e9c88c6da77be740bd2ff85e5c7aa481f9f") // 1111
        //_ = KeychainUtils.saveCurrentUserToken("f097f5f3a6a5efb60914cb4498f24255bcbf6cdc") // 1113
        //_ = KeychainUtils.saveCurrentUserToken("af4ec9e98ce88d81efc84be872ee6d4a98a22f0c") // 1114
        //_ = KeychainUtils.saveCurrentUserToken("1f69378278eccaf35fc458d727c38225f395bc5a") // Sash
        //_ = KeychainUtils.saveCurrentUserToken("f09084fc8b55f67206431dcf8319d43246def7b8") // Kolia
        //_ = KeychainUtils.saveCurrentUserToken("e981564a88347b92e2f22b034d58043621eb4996") // Drugs
        //_ = KeychainUtils.saveCurrentUserToken("2e8cdb781fcc1b8fe1ba20f07ceb3a25b5b3ad2d") // SpikeJankins
        //_ = KeychainUtils.saveCurrentUserToken("ee07d3403bfea7205f1c62021fb2b5c3ce9dab97") // Nika
        //_ = KeychainUtils.saveCurrentUserToken("5af2236b40302080ee42a6d1af34b17e2554a1f0") // Full Stack
        //_ = KeychainUtils.removeCurrentUserToken() // clear token
        
        //ImageCM.shared.clear()
        
        if UCardSingleManager.shared.isUserToken() {
            UCardSingleManager.shared.getCurrUser(request: true)
        } else {
           UCardSingleManager.shared.user.getFromUserDef()
        }
        
        PushNotificationManager.shared.didFinishLaunchingWithOptions(launchOptions)
        
        ListDHUSingleManager.shared.updateDefaultLists()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        
        ChatsSinglManager.shared.updateUnreadedChatsCount()
        //_ = HealthDataController.shared
        
        FirebaseApp.configure()
        
        // TESTS:
        // Date.testCases()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("### N uI \(userInfo)")
        //ChatsSinglManager.shared.appIconDelegate?.gotNewMessage(1)
        //PushNotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
        //application.applicationIconBadgeNumber = 1
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.shared.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.shared.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        print("### N \(notification)")
        PushNotificationManager.shared.userNotificationCenterwillPresent(notification: notification)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("### didReceive response \(userInfo)")
        let tabBarController = self.window?.rootViewController as? UITabBarController
        let navController = tabBarController?.selectedViewController as? UINavigationController
        //print("### navController \(String(describing: navController))")
        PushNotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo, navController: navController)
        completionHandler()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

