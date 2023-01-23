//
//  ProfileController.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 10.08.2022.
//

import UIKit

final class ProfileController: BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }

    private let mainView = ProfileMainView()
    
    override func loadView() {
        mainView.delegate = self
        view = mainView
    }
}

extension ProfileController: ProfileMainViewDelegate {
    func signOut() {
        Settings.shared.username = nil
        Settings.shared.userPassword = nil
        Settings.shared.accessToken = nil
        Settings.shared.refreshToken = nil
        let navigation = UINavigationController(rootViewController: LoginViewController())
        view?.window?.rootViewController = navigation
    }
}
