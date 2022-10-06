//
//  LoginScreenViewController.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 18.07.2022.
//

import UIKit

final class LoginViewController: BaseViewController {
    private let mainView = LoginMainView(frame: UIScreen.main.bounds)
    
    override func loadView() {
        mainView.delegate = self
        view = mainView
    }

    override func errorHandle(_ error: Error) {
        var message: String = "Unexpected error"

        if let error = error as? LoginModuleError {
            message = error.description
        }

        if let error = error as? ErrorResponse {
            message = error.description
        }

        let alert = createAlert(title: "Error!", message: message, actionTitle: "Cancel", actionHandler: nil)
        present(alert, animated: true)
    }
}

extension LoginViewController: LoginMainViewDelegate {
    func signOn(username: String, password: String) {
        let request = AuthenticationRequest(username: username, password: password)
        let communicator = HTTPCommunicator()
        
        communicator.request(request) { [weak self] result in
            defer { self?.mainView.isLoading = false }

            switch result {
            case .success(let tokens): 
                Settings.shared.refreshToken = tokens.refresh
                Settings.shared.accessToken = tokens.access
                Settings.shared.username = username
                Settings.shared.userPassword = password
                self?.view.window?.rootViewController = MainController()
            case .failure(let error):
                self?.errorHandle(error)
            }
        }
    }
}
