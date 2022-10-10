//
//  Camera.swift
//  GCoreVodDemo
//
//  Created by Evgeniy Polyubin on 09.08.2022.
//

import Foundation
import AVFoundation

enum CameraSetupError: Error {
    case accessDevices, initializeCameraInputs
}

protocol CameraDelegate: AnyObject {
    func addRecordedMovie(url: URL, time: CMTime)
    func updateCurrentRecordedTime(_ time: CMTime)
}

final class Camera: NSObject {
    var movieOutput: AVCaptureMovieFileOutput! {
        didSet {
            movieOutput.maxRecordedDuration = CMTime(seconds: 121, preferredTimescale: 600)
        }
    }
    weak var delegate: CameraDelegate?
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var rearCameraInput: AVCaptureDeviceInput!
    private var frontCameraInput: AVCaptureDeviceInput!
    private let captureSession: AVCaptureSession
    
    private var timer: Timer? 
    
    init(captureSession: AVCaptureSession) throws {
        self.captureSession = captureSession
        
        //check access to devices and setup them
        guard let rearCamera = AVCaptureDevice.default(for: .video),
              let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let audioInput = AVCaptureDevice.default(for: .audio)
        else {
            throw CameraSetupError.accessDevices
        }
        
        do {
            let rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            let frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            let audioInput = try AVCaptureDeviceInput(device: audioInput)
            let movieOutput = AVCaptureMovieFileOutput()
            
            if captureSession.canAddInput(rearCameraInput), captureSession.canAddInput(audioInput),
               captureSession.canAddInput(frontCameraInput),  captureSession.canAddOutput(movieOutput) {
                
                captureSession.addInput(rearCameraInput)
                captureSession.addInput(audioInput)
                self.videoDeviceInput = rearCameraInput
                self.rearCameraInput = rearCameraInput
                self.frontCameraInput = frontCameraInput
                captureSession.addOutput(movieOutput)
                self.movieOutput = movieOutput
            }
            
        } catch {
            throw CameraSetupError.initializeCameraInputs
        }
    }
    
    func flipCamera() {
        guard let rearCameraIn = rearCameraInput, let frontCameraIn = frontCameraInput else { return }
        if captureSession.inputs.contains(rearCameraIn) {
            captureSession.removeInput(rearCameraIn)
            captureSession.addInput(frontCameraIn)
        } else {
            captureSession.removeInput(frontCameraIn)
            captureSession.addInput(rearCameraIn)
        }
    }
    
    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }

    func startRecording() {
        if movieOutput.isRecording == false {
            guard let outputURL = temporaryURL() else { return }
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                self.timer?.fire()
            }
        } else {
            stopRecording()
        }
    }
    
    private func temporaryURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(UUID().uuidString + ".mov")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    @objc func updateTime() {
        delegate?.updateCurrentRecordedTime(movieOutput.recordedDuration)
    }
}

//MARK: - AVCaptureFileOutputRecordingDelegate
//When the shooting of one clip ends, throws a link to the file to the delegate
extension Camera: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
        } else {
            timer?.invalidate()
            timer = nil
            delegate?.addRecordedMovie(url: outputFileURL, time: output.recordedDuration)
        }
    }
}
