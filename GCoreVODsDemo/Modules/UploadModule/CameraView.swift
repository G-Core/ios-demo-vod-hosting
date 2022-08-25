//
//  CameraView.swift
//  GCoreVODsDemo
//
//  Created by Evgeniy Polyubin on 09.08.2022.
//

import UIKit
import AVFoundation
import AVKit

protocol CameraViewDelegate: AnyObject {
    func tappedRecord(isRecord: Bool)
    func tappedFlipCamera()
    func tappedUpload()
    func tappedDeleteClip()
    func shouldRecord() -> Bool
}

final class CameraView: UIView {
    var isRecord = false {
        didSet {
            if isRecord {
                recordButton.setImage(UIImage(named: "pause.icon"), for: .normal)
            } else {
                recordButton.setImage(UIImage(named: "play.icon"), for: .normal)
            }
        }
    }
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraViewDelegate?
    
    let recordButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play.icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapRecord), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let flipCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "flip.icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapFlip), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "upload.icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapUpload), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let clipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "Clips: 0"
        
        return label
    }()
    
    let deleteLastClipButton: Button = {
        let button = Button()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "delete.left.fill"), for: .normal)
        button.addTarget(self, action: #selector(tapDeleteClip), for: .touchUpInside)
        
        return button
    }()
    
    let recordedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0s / \(maxRecordTime)s"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .left
        
        return label
    }()
    
    
    func setupLivePreview(session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        self.previewLayer = previewLayer
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        layer.addSublayer(previewLayer)
        session.startRunning()
        backgroundColor = .black
    }
    
    override func layoutSubviews() {
        previewLayer?.frame = bounds
    }
    
    convenience init(session: AVCaptureSession) {
        self.init(frame: .zero)
        setupLivePreview(session: session)
        addSubview(recordButton)
        addSubview(flipCameraButton)
        addSubview(uploadButton)
        initLayout()
    }
    
    private func initLayout() {
        [clipsLabel, deleteLastClipButton, recordedTimeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            flipCameraButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            flipCameraButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 30),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 30),
            
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            recordButton.widthAnchor.constraint(equalToConstant: 30),
            recordButton.widthAnchor.constraint(equalToConstant: 30),
            
            uploadButton.leftAnchor.constraint(equalTo: recordButton.rightAnchor, constant: 20),
            uploadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            uploadButton.widthAnchor.constraint(equalToConstant: 30),
            uploadButton.widthAnchor.constraint(equalToConstant: 30),
            
            clipsLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            clipsLabel.centerYAnchor.constraint(equalTo: uploadButton.centerYAnchor),
            
            deleteLastClipButton.centerYAnchor.constraint(equalTo: clipsLabel.centerYAnchor),
            deleteLastClipButton.rightAnchor.constraint(equalTo: recordButton.leftAnchor, constant: -15),
            deleteLastClipButton.widthAnchor.constraint(equalToConstant: 30),
            deleteLastClipButton.widthAnchor.constraint(equalToConstant: 30),
            
            recordedTimeLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            recordedTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5)
        ])
    }
    
    @objc func tapRecord() {
        guard delegate?.shouldRecord() == true else { return }
        isRecord = !isRecord
        delegate?.tappedRecord(isRecord: isRecord)
    }
    
    @objc func tapFlip() {
        delegate?.tappedFlipCamera()
    }
    
    @objc func tapUpload() {
        delegate?.tappedUpload()
    }
    
    @objc func tapDeleteClip() {
        delegate?.tappedDeleteClip()
    }
}
