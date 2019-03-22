//
//  AppDelegate.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-21.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FBSDKCoreKit
import AudioToolbox
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //App Customisations
        UINavigationBar.appearance().barTintColor = .facebookBlue()
        application.statusBarStyle = .lightContent
        
        //Firebase
        FirebaseApp.configure()
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UNUserNotificationCenter.current().delegate = self
        
        //Setup Logged in and out Views
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        if FBSDKAccessToken.current() != nil {
            let home = HomeController()
            let navigationController = UINavigationController(rootViewController: home)
            self.window?.rootViewController = navigationController
        } else {
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                let login = LoginController(collectionViewLayout: layout)
                self.window?.rootViewController = login
        }
        return true
    }
  
    private func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL?, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for notifications", deviceToken)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registered with fcmToken", fcmToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if (userInfo["fromId"] as? String) != nil {
            let soundID: SystemSoundID = 1003
            AudioServicesPlayAlertSoundWithCompletion(soundID, nil)
        } else {
            completionHandler(.alert)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let fromId = (userInfo["fromId"] as? String) {
            
            Database.fetchUserWithUID(uid: fromId) { (user) in
                let homeController = HomeController()
                let navigtaionController = UINavigationController(rootViewController: homeController)
                self.window?.rootViewController = navigtaionController
                homeController.pushSender = user
            }
        }
    }

}

