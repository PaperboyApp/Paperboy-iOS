//
//  AppDelegate.swift
//  Paperboy
//
//  Created by Mario Encina on 1/12/15.
//  Copyright (c) 2015 Paperboy, Inc. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Parse init
        Parse.setApplicationId("0gioPPsSyHjGFajF4CpCPpZijn5YvDymitWvGp9i", clientKey: "gAgs67GR7NXcRtLkP2Sid1gbYftNoxPsy1LrtbuK")
        
        // User not loged in, send him to Verification.storyboard
        if PFUser.currentUser() == nil {
            let storyboard = UIStoryboard(name: "Verification", bundle: nil)
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = storyboard.instantiateInitialViewController() as? UIViewController
            self.window?.makeKeyAndVisible()
        }
        
        // Push processing
        if let launchOpts = launchOptions {
            let userInfo = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey] as NSDictionary
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "postNotification:", userInfo: userInfo, repeats: false)
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        // Register device token
        var currentInstalation: PFInstallation = PFInstallation.currentInstallation()
        currentInstalation.setDeviceTokenFromData(deviceToken)
        
        // Save installation
        currentInstalation.saveEventually()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSNotificationCenter.defaultCenter().postNotificationName("pushNotification", object: nil, userInfo: userInfo)
    }
    
    func postNotification(timer: NSTimer) {
        let userInfo = timer.userInfo as NSDictionary
        NSNotificationCenter.defaultCenter().postNotificationName("pushNotification", object: nil, userInfo: userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

