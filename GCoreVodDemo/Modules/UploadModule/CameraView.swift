//
//  CameraView.swift
//  GCoreVodDemo
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
                if #available(iOS 13, *) {
                    recordButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                } else {
                    recordButton.setImage(UIImage(named: "pause.icon"), for: .normal)
                }
            } else {
                if #available(iOS 13, *) {
                    recordButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                } else {
                    recordButton.setImage(UIImage(named: "play.icon"), for: .normal)
                }
            }
        }
    }
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraViewDelegate?

    var stackView: UIStackView!

    let recordButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapRecord), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 13, *) {
            button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            button.setImage(UIImage(named: "play.icon"), for: .normal)
        }

        return button
    }()
    
    let flipCameraButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapFlip), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 13, *) {
            button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill"), for: .normal)
        } else {
            button.setImage(UIImage(named: "flip.icon"), for: .normal)
        }
        
        return button
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(tapUpload), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 13, *) {
            button.setImage(UIImage(systemName: "square.and.arrow.up.fill"), for: .normal)
        } else {
            button.setImage(UIImage(named: "upload.icon"), for: .normal)
        }
        
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
        button.addTarget(self, action: #selector(tapDeleteClip), for: .touchUpInside)

        if #available(iOS 13, *) {
            button.setImage(UIImage(systemName: "delete.backward.fill"), for: .normal)
        } else {
            button.setImage(UIImage(named: "delete.left.fill"), for: .normal)
        }
        
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
        backgroundColor = .black

        DispatchQueue.global().async {
            session.startRunning()
        }
    }

    override func layoutSubviews() {
        previewLayer?.frame = bounds
    }

    convenience init(session: AVCaptureSession) {
        self.init(frame: .zero)
        setupLivePreview(session: session)
        addSubview(flipCameraButton)
        initLayout()
    }

    private func initLayout() {
        [clipsLabel, deleteLastClipButton, recordedTimeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        [deleteLastClipButton, recordButton, uploadButton, flipCameraButton].forEach {
            $0.imageView?.contentMode = .scaleAspectFill
            $0.contentVerticalAlignment = .fill
            $0.contentHorizontalAlignment = .fill
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
            $0.imageView?.tintColor = .white
        }

        stackView = UIStackView(arrangedSubviews: [deleteLastClipButton, recordButton, uploadButton])
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            uploadButton.heightAnchor.constraint(equalToConstant: 60),

            flipCameraButton.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            flipCameraButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 30),
            flipCameraButton.widthAnchor.constraint(equalToConstant: 30),

            clipsLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            clipsLabel.centerYAnchor.constraint(equalTo: uploadButton.centerYAnchor),

            recordedTimeLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            recordedTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),

            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 30)
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
