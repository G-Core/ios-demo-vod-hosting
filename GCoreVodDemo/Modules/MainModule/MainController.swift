//
//  MainController.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import UIKit

final class MainController: UITabBarController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .white
        
        let strokeView = UIView()
        strokeView.translatesAutoresizingMaskIntoConstraints = false
        strokeView.backgroundColor = .grey800
        tabBar.addSubview(strokeView)
        tabBar.tintColor = .red
        
        NSLayoutConstraint.activate([
            strokeView.widthAnchor.constraint(equalToConstant: ScreenSize.width),
            strokeView.heightAnchor.constraint(equalToConstant: 1),
            strokeView.topAnchor.constraint(equalTo: tabBar.topAnchor),
        ])
        
        let viewingVC = ViewingController()
        viewingVC.tabBarItem = .init(
            title: "Viewing",
            image: .viewingIcon, 
            selectedImage: .viewingSelectedIcon.withRenderingMode(.alwaysOriginal)
        )
        
        let uploadVC = UploadController()
        uploadVC.tabBarItem = .init(
            title: "Upload",
            image: .uploadIcon, 
            selectedImage: .uploadSelectedIcon.withRenderingMode(.alwaysOriginal)
        )
        
        let profileVC = ProfileController()
        profileVC.tabBarItem = .init(
            title: "Account",
            image: .accountIcon, 
            selectedImage: .uploadSelectedIcon.withRenderingMode(.alwaysOriginal)
        )
        
        let smoothScrollVC = SmoothScrollingController()
        smoothScrollVC.tabBarItem = .init(
            title: "Viewing",
            image: .viewingIcon, 
            selectedImage: .viewingSelectedIcon.withRenderingMode(.alwaysOriginal)
        )

        viewControllers = [smoothScrollVC, uploadVC, profileVC]
    }   
}
