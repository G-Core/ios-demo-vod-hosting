//
//  AppDelegate.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import UIKit
import Network

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var isOnline = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if Settings.shared.accessToken != nil {
            window?.rootViewController = MainController()
        } else {
            window?.rootViewController = LoginViewController()
        }
        
        window?.makeKeyAndVisible()
        return true
    }
}

