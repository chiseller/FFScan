//
//  AppDelegate.swift
//  FFScanDemo
//
//  Created by fingle on 2020/4/30.
//  Copyright © 2020 fingle0618. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let root = UINavigationController(rootViewController: FFScanController())
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        return true
    }

   


}

