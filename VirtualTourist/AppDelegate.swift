//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Dean Copeland on 5/1/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import CoreData

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    
    
    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            //print("App has launched before")
        } else {
            //print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: Defaults.HasLaunchedBeforeKey)
            
            UserDefaults.standard.set(Defaults.DefaultCenterLat, forKey: Defaults.CenterLatitude)
            UserDefaults.standard.set(Defaults.DefaultCenterLon, forKey: Defaults.CenterLongitude)
            UserDefaults.standard.set(Defaults.DefaultSpanLat, forKey: Defaults.SpanLatitude)
            UserDefaults.standard.set(Defaults.DefaultSpanLon, forKey: Defaults.SpanLongitude)
            UserDefaults.standard.synchronize()
        }
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Usually this is not overridden. Using the "did finish launching" method is more typical
        //print("App Delegate: will finish launching")
        
        checkIfFirstLaunch()
        return true
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Start Autosaving
        stack.autoSave(60)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        stack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        stack.save()
    }

}

