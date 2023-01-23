//
//  SmoothScrollingController.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 15.08.2022.
//

import UIKit
import AVKit
import AsyncDisplayKit

enum SmoothScrollingType {
    case common, demo
}

final class SmoothScrollingController: BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    var type: SmoothScrollingType = .common

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

        if type == .common {
            loadVideos(page: 1, isNextPage: true)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.tableManager.add(loadedData: VOD.mock, isNextPage: true)
                self?.mainView.state = .content
            }
        }
        if type == .common {
            NSLayoutConstraint.activate([
                mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                mainView.leftAnchor.constraint(equalTo: view.leftAnchor),
                mainView.rightAnchor.constraint(equalTo: view.rightAnchor),
                mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                mainView.leftAnchor.constraint(equalTo: view.leftAnchor),
                mainView.rightAnchor.constraint(equalTo: view.rightAnchor),
                mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        tabBarController?.tabBar.barTintColor = .black
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = .white
        tabBarController?.tabBar.barTintColor = .white
    }

    override func errorHandle(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.tableManager.currentData.isEmpty {
                self.mainView.state = .empty
            }
            
            if let error = error as? ErrorResponse {
                
                switch error {
                case .invalidCredentials:
                    let action: ((UIAlertAction) -> Void)? = { [self] _ in
                        self.mainView.window?.rootViewController = LoginViewController()
                    }
                    
                    let alert = self.createAlert(title: error.description, actionHandler: action)
                    self.present(alert, animated: true)
                    
                default:
                    self.present(self.createAlert(title: error.description), animated: true)
                }
            } else {
                self.present(self.createAlert(), animated: true)
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
        guard !isLoading && type == .common else { return }
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

        http.request(requst) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                defer { self.isLoading = false }

                switch result {
                case .failure(let error):
                    self.stopTimer()

                    if let error = error as? ErrorResponse, error == .invalidToken {
                        Settings.shared.accessToken = nil
                        self.refreshToken()
                    } else {
                        self.errorHandle(error)
                    }

                case .success(let vodArray):
                    self.tableManager.add(loadedData: vodArray, isNextPage: isNextPage)
                    guard !self.tableManager.currentData.isEmpty else {
                        return self.mainView.state = .empty
                    }
                    self.mainView.state = .content   
                }
            }
        }
    }

    func onNextDataAdded() {
        stopTimer()
    }
}
