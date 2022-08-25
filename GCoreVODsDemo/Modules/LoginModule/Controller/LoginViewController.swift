//
//  LoginScreenViewController.swift
//  GCoreVODsDemo
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func errorHandle(_ error: Error) {
        print((error as NSError).description)
    }
}

extension LoginViewController: LoginMainViewDelegate {
    func signOn(username: String, password: String) {
        let request = AuthenticationRequest(username: username, password: password)
        let communicator = HTTPCommunicator()
        
        communicator.request(request) { [weak self] result in
            switch result {
            case .success(let tokens): 
                Settings.shared.refreshToken = tokens.refresh
                Settings.shared.accessToken = tokens.access
                Settings.shared.username = username
                Settings.shared.userPassword = password
                DispatchQueue.main.async {
                    self?.view.window?.rootViewController = MainController()
                }
            case .failure(let error):
                self?.errorHandle(error)
            }
        }
    }
}
