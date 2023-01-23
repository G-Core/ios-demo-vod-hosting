//
//  AppDelegate.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }

        window = UIWindow(frame: UIScreen.main.bounds)

        if Settings.shared.accessToken != nil {
            window?.rootViewController = MainController()
        } else {
            window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        }

        if #available(iOS 13, *) {
            window?.overrideUserInterfaceStyle = .light
        }

        window?.makeKeyAndVisible()
        return true
    }
}

