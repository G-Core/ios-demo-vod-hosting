//
//  UploadController.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import TUSKit
import AVFoundation
import UIKit

final class UploadController: BaseViewController {
    private let mainView = UploadMainView()

    private var camera: Camera?
    private var captureSession = AVCaptureSession()
    private var filename = ""
    private var writingVideoURL: URL!
    private var lastRecordedTime: Double = 0
    
    private var totalRecordedTime: Double = 0 {
        didSet {
            if totalRecordedTime >= maxRecordTime {
                camera?.stopRecording()
                mainView.cameraView?.isRecord = false
            } else if totalRecordedTime < 0 {
                totalRecordedTime = 0
            }
            mainView.cameraView?.recordedTimeLabel.text = "\(Int(totalRecordedTime))s / \(maxRecordTime)s"
        }
    }
    
    private var currentRecordedTime: Double = 0 {
        didSet { totalRecordedTime = lastRecordedTime + currentRecordedTime }
    }
    
    private var clips: [(URL, CMTime)] = [] {
        didSet { mainView.cameraView?.clipsLabel.text = "Clips: \(clips.count)" }
    }
    
    private var isUploading = false {
        didSet { mainView.state = isUploading ? .upload : .common }
    }

    override func loadView() {
        mainView.delegate = self
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            camera = try Camera(captureSession: captureSession)
            camera?.delegate = self
            mainView.cameraView = CameraView(session: captureSession)
            mainView.cameraView?.delegate = self
        } catch {
            debugPrint((error as NSError).description)
            mainView.state = .error
        }
    }
    
    private func mergeSegmentsAndUpload() {
        guard !isUploading, let camera = camera else { return }
        isUploading = true
        camera.stopRecording()
        
        if let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let clips = clips.map { $0.0 }
            VideoCompositionWriter().mergeVideo(directoryURL, filename: "\(filename).mp4", clips: clips) { [weak self] success, outURL in
                guard let self = self else { return }
    
                if success, let outURL = outURL {
                    clips.forEach { try? FileManager.default.removeItem(at: $0) }
                    self.clips = []
                    self.lastRecordedTime = 0
                    self.totalRecordedTime = 0
                    self.currentRecordedTime = 0
                   
                    let videoData = try! Data.init(contentsOf: outURL)
                    let writingURL = FileManager.default.temporaryDirectory.appendingPathComponent(outURL.lastPathComponent)
                    try! videoData.write(to: writingURL)
                    self.writingVideoURL = writingURL
                    self.createVideoPlaceholderOnServer()
                } else {
                    self.isUploading = false
                    self.mainView.state = .common
                    self.present(self.createAlert(), animated: true)
                }
            }
        }
    }

    private func createVideoPlaceholderOnServer() {                
        guard let token = Settings.shared.accessToken else { 
            refreshToken()
            return
        }
        
        let http = HTTPCommunicator()
        let request = CreateVideoRequest(token: token, videoName: filename)
        
        http.request(request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let vod):
                self.loadMetadataFor(vod: vod)
            case .failure(let error):
                if let error = error as? ErrorResponse, error == .invalidToken {
                    Settings.shared.accessToken = nil
                    self.refreshToken()
                } else {
                    self.errorHandle(error)
                }
            }
        }
    }
    
    func loadMetadataFor(vod: VOD) {
        guard let token = Settings.shared.accessToken else { 
            refreshToken()
            return
        }
        
        let http = HTTPCommunicator()
        let request = VideoMetadataRequest(token: token, videoId: vod.id)
        http.request(request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let metadata):
                self.uploadVideo(with: metadata)
            case .failure(let error): 
                if let error = error as? ErrorResponse, error == .invalidToken {
                    Settings.shared.accessToken = nil
                    self.refreshToken()
                } else {
                    self.errorHandle(error)
                }
            }
        }
    }
    
    func uploadVideo(with metadata: VideoMetadata) {
        var config = TUSConfig(withUploadURLString: metadata.uploadURLString)
        config.logLevel = .All
        
        TUSClient.setup(with: config)
        TUSClient.shared.delegate = self
        
        let upload: TUSUpload = TUSUpload(withId:  filename,
                                          andFilePathURL: writingVideoURL,
                                          andFileType: ".mp4")
        upload.metadata = [
            "filename" : filename,
            "client_id" : String(metadata.video.clientID),
            "video_id" : String(metadata.video.id),
            "token" : metadata.token
        ]
        
        TUSClient.shared.createOrResume(forUpload: upload)
    }
    
    override func errorHandle(_ error: Error) {
        guard let error = error as? ErrorResponse else {     
            let alert = createAlert(title: ErrorResponse.unexpectedError.rawValue)
            present(alert, animated: true)
            return
        }
        
        switch error {
        case .invalidCredentials:
            let actionHandler: ((UIAlertAction) -> Void) = { [weak self] _ in
                self?.view.window?.rootViewController = LoginViewController()
            }
            let alert = createAlert(title: error.rawValue, actionHandler: actionHandler)
            present(alert, animated: true)

        default: 
            break
        }
    }
    
    override func tokenDidUpdate() {
        createVideoPlaceholderOnServer()
    }
}

//MARK: - Extension for UITextFieldDelegate and TUSDelegate
extension UploadController: TUSDelegate {
    
    func TUSProgress(bytesUploaded uploaded: Int, bytesRemaining remaining: Int) { }
    func TUSProgress(forUpload upload: TUSUpload, bytesUploaded uploaded: Int, bytesRemaining remaining: Int) {  }
    func TUSFailure(forUpload upload: TUSUpload?, withResponse response: TUSResponse?, andError error: Error?) {
        if let error = error {
            print((error as NSError).description)
        }
        present(createAlert(), animated: true)
        mainView.state = .common
    }
    
    func TUSSuccess(forUpload upload: TUSUpload) {
        let alert = createAlert(title: "Upload success")
        present(alert, animated: true)
        mainView.state = .common
    }
}

//MARK: - extensions GCCameraViewDelegate, GCCameraDelegate
extension UploadController: CameraViewDelegate, CameraDelegate {
    func updateCurrentRecordedTime(_ time: CMTime) {
        currentRecordedTime = time.seconds
    }
    
    func tappedDeleteClip() {
        guard let lastClip = clips.last else { return }
        lastRecordedTime -= lastClip.1.seconds
        clips.removeLast()
    }
    
    func addRecordedMovie(url: URL, time: CMTime) {
        lastRecordedTime += time.seconds
        clips += [(url, time)]
    }
    
    func shouldRecord() -> Bool {
        totalRecordedTime < maxRecordTime
    }

    func tappedRecord(isRecord: Bool) {
        isRecord ? camera?.startRecording() : camera?.stopRecording()
    }

    func tappedUpload() {
        guard !clips.isEmpty && filename != "" else { return }
        mergeSegmentsAndUpload()
    }

    func tappedFlipCamera() {
        camera?.flipCamera()
    }
}

extension UploadController: UploadMainViewDelegate {
    func videoNameDidUpdate(_ name: String) {
        filename = name
    }
}
