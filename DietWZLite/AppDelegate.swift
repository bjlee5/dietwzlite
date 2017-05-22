//
//  AppDelegate.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 23/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit
//import PermissionScope
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func initializeParse() {
        
        let config = ParseClientConfiguration(block: {
            (ParseMutableClientConfiguration) -> Void in
            
            ParseMutableClientConfiguration.applicationId = "sRHLE6iq9coijChMOvaBCGwbMuJqPot0tHaLS4ZX"
            ParseMutableClientConfiguration.clientKey = "jpm3QdK9Ap2Y6eYIeoobomy56IxsDHH2XLIVCs49"
            ParseMutableClientConfiguration.server = DIETWZ_URL.PARSE 
            ParseMutableClientConfiguration.isLocalDatastoreEnabled = true
        });
        
        
        Parse.initialize(with: config)
        PFUser.enableRevocableSessionInBackground()
        registerParseClasses()

        
        let currentUser = PFUser.current()
        dlog("1. currentUser  \(currentUser?.email) ")
        let defaultACL = PFACL()
        defaultACL.getPublicReadAccess = false
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
        _ = Utils.sharedInstance
        Utils.sharedInstance.checkVersionControl()
        
        if(currentUser != nil ) {
            Utils.sharedInstance.userInfo.deSerializeFromPFUser(currentUser!)
            let currentInstallation:PFInstallation = PFInstallation.current()
            currentInstallation.setObject(currentUser!, forKey: "user")
            currentInstallation.saveInBackground(block: nil)
            Crashlytics.sharedInstance().setUserEmail(currentUser?.email)
            Crashlytics.sharedInstance().setUserIdentifier(currentUser?.objectId)
            Crashlytics.sharedInstance().setUserName(currentUser?.username)
            Answers.logCustomEvent(withName: "App Launched", customAttributes: ["user": (currentUser?.username)!, "device": "iOS"])
        }
    }
    
    func registerParseClasses() {
        UserProfile.registerSubclass()
        CategoryInfo.registerSubclass()
        DeviceInfo.registerSubclass()
        DailyCategoryInfo.registerSubclass()
        DailyInfo.registerSubclass()
        HealthyAlternatives.registerSubclass()
        Recipes.registerSubclass()
        FriendGroup.registerSubclass()
        UserGroupPreference.registerSubclass()
        Invitation.registerSubclass()
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let homeDir = "Local Parse Directory \n" + NSHomeDirectory() + "/Library/Private Documents/Parse"
        dlog(homeDir)
        
        Fabric.with([Crashlytics.self])
        dlog("************** >>>>>>>>>>>>>>>>>>  App started loading at \(Date())")
        application.statusBarStyle = .lightContent
        window?.tintColor = ThemeColors.Teal
        UITabBar.appearance().barTintColor = ThemeColors.TabBarColor
        initializeParse()
        
        dlog("launchOptions \(launchOptions)")
        
//        Utils.sharedInstance
        
//        let pscope = PermissionScope()
//        pscope.addPermission(ContactsPermission(),
//            message: "We use this to steal\r\nyour friends")
//        pscope.addPermission(NotificationsPermission(notificationCategories: nil),
//            message: "We use this to send you\r\nspam and love notes")
//
//        
//        // Show dialog with callbacks
//        pscope.show({ finished, results in
//            print("got results \(results)")
//            }, cancelled: { (results) -> Void in
//                print("thing was cancelled")
//        })
        
        
        //registering for sending user various kinds of notifications
//        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil))
//        application.registerForRemoteNotifications()
        PFAnalytics.trackAppOpenedWithLaunchOptions(inBackground: launchOptions, block: nil)
        
        let currentInstallation:PFInstallation = PFInstallation.current()
        currentInstallation.saveInBackground(block: nil)
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification){
        dlog("Received local notification \(Date())")
//        Utils.sharedInstance.checkNewDay()
        goToLoginScreen()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        dlog("saving to parse - applicationWillResignActive")
        Utils.sharedInstance.saveToParse()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        dlog("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        dlog("applicationWillEnterForeground")
        //check new day only if there is an active logged in user
//        goToLoginScreen()
//        Utils.sharedInstance.checkNewDay()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        dlog("registerNotifiacation - applicationDidBecomeActive")
        Utils.sharedInstance.registerNotifiacation()
        goToLoginScreen()
        
//        Utils.sharedInstance.checkNewDay()
//        Utils.sharedInstance.checkPoints()
//        dlog("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        dlog("applicationWillTerminate")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        dlog("didRegisterForRemoteNotificationsWithDeviceToken")
        let currentInstallation:PFInstallation = PFInstallation.current()
        currentInstallation.setDeviceTokenFrom(deviceToken)
        currentInstallation.saveInBackground(block: nil)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        dlog("didRegisterUserNotificationSettings")
        UIApplication.shared.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        dlog(error.localizedDescription)
    }
    
    func goToLoginScreen() {
        dlog("Go to login screen invoked")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_APPLICATION_ACTIVATED), object: nil)
//        var rootViewController = self.window!.rootViewController
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        var setViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loginViewController") as? LoginViewController
//        rootViewController!.navigationController?.popToViewController(setViewController!, animated: false)
    }
    


}

