//
//  SmoothScrollingController.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 15.08.2022.
//

import UIKit
import AVKit
import AsyncDisplayKit

final class SmoothScrollingController: BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private let mainView = SmoothScrollingMainView()
    private let tableManager = VideoTableManager()

    private var isLoading = false

    private var timer: Timer?
    private var timeToRepeateRequest = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainView)

        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = .black
        view.addSubview(statusBarView)

        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.state = .proccess

        tableManager.tableView = mainView.tableView
        tableManager.delegate = self

        loadVideos(page: 1, isNextPage: true)

        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            mainView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.barTintColor = .black
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.barTintColor = .white
    }

    override func errorHandle(_ error: Error) {
        DispatchQueue.main.async { [self] in
            if tableManager.currentData.isEmpty {
                mainView.state = .empty
            }
            
            if let error = error as? ErrorResponse {
                
                switch error {
                case .invalidCredentials:
                    let action: ((UIAlertAction) -> Void)? = { [self] _ in
                        mainView.window?.rootViewController = LoginViewController()
                    }
                    
                    let alert = createAlert(title: error.description, actionHandler: action)
                    present(alert, animated: true)
                    
                default:
                    present(self.createAlert(title: error.description), animated: true)
                }
            } else {
                present(self.createAlert(), animated: true)
            }
        }
    }
    
    override func tokenDidUpdate() {
        if tableManager.currentData.isEmpty {
            loadVideos(page: 1, isNextPage: true)
        } 
    }

    private func launchTimer() {
        timeToRepeateRequest = 10
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            timeToRepeateRequest -= 1
            if timeToRepeateRequest <= 0 {
                stopTimer()
            }
        }
        timer?.fire()
    }

    private func stopTimer() {
        timeToRepeateRequest = 0
        timer?.invalidate()
        self.timer = nil
    }
}

// MARK: - SmoothScrollingMainViewDelegate
extension SmoothScrollingController: SmoothScrollingMainViewDelegate {
    func reload() {
        loadVideos(page: 1, isNextPage: true)
    }
}

// MARK: VodTableManagerDelegate
extension SmoothScrollingController: VideoTableManagerDelegate {
    func loadVideos(page: Int, isNextPage: Bool) {
        guard !isLoading else { return }
        if isNextPage && timeToRepeateRequest > 0 {
            return
        }

        guard let token = Settings.shared.accessToken else {
            return refreshToken()
        }

        isLoading = true

        if mainView.state == .empty {
            mainView.state = .proccess
        }

        let http = HTTPCommunicator()
        let requst = VODRequest(token: token, page: page)

        if isNextPage {
            launchTimer()
        }

        http.request(requst) { [self] result in
            DispatchQueue.main.async { [self] in
                defer { isLoading = false }

                switch result {
                case .failure(let error):
                    stopTimer()

                    if let error = error as? ErrorResponse, error == .invalidToken {
                        Settings.shared.accessToken = nil
                        refreshToken()
                    } else {
                        errorHandle(error)
                    }

                case .success(let vodArray):
                    tableManager.add(loadedData: vodArray, isNextPage: isNextPage)
                    guard !tableManager.currentData.isEmpty else {
                        return mainView.state = .empty
                    }
                    mainView.state = .content   
                }
            }
        }
    }

    func onNextDataAdded() {
        stopTimer()
    }
}
