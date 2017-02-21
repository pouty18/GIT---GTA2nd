//
//  AppDelegate.swift
//  Game Theory App 2
//
//  Created by Richard Poutier on 2/19/17.
//  Copyright © 2017 Richard Poutier. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate:  FIRMessagingRemoteMessage, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FIRApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


    
//    // [END refresh_token]
//    // [START connect_to_fcm]
//    func connectToFcm() {
//        // Won't connect since there is no token
//        guard FIRInstanceID.instanceID().token() != nil else {
//            return;
//        }
//        
//        // Disconnect previous FCM connection if it exists.
//        FIRMessaging.messaging().disconnect()
//        
//        FIRMessaging.messaging().connect { (error) in
//            if error != nil {
//                print("Unable to connect with FCM. \(error)")
//            } else {
//                print("Connected to FCM.")
//            }
//        }
//    }
//    // [END connect_to_fcm]
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Unable to register for remote notifications: \(error.localizedDescription)")
//    }
//    
//    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
//    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
//    // the InstanceID token.
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        print("APNs token retrieved: \(deviceToken)")
//        
//        // With swizzling disabled you must set the APNs token here.
//        // FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
//    }
//    
//    // [START connect_on_active]
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        connectToFcm()
//    }
//    // [END connect_on_active]
//    // [START disconnect_from_fcm]
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        FIRMessaging.messaging().disconnect()
//        print("Disconnected from FCM.")
//    }
//    // [END disconnect_from_fcm]
//}

//// [START ios_10_message_handling]
//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//    
//    // Receive displayed notifications for iOS 10 devices.
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//        
//        // Change this to your preferred presentation option
//        completionHandler([])
//    }
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
//        
//        // Print full message.
//        print(userInfo)
//        
//        completionHandler()
//    }
//}
//
// [END ios_10_message_handling]

// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}
