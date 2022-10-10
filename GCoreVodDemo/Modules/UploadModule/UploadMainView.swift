//
//  UploadMainView.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import UIKit
import AVFoundation

protocol UploadMainViewDelegate: AnyObject {
    func videoNameDidUpdate(_ name: String)
}

final class UploadMainView: UIView {
    enum State {
        case upload, error, common
    }
    
    private var keyboardBottomConstraint: NSLayoutConstraint?
    
    var cameraView: CameraView? {
        didSet { initLayoutForCameraView() }
    }
    
    var state: State = .common {
        didSet {
            switch state {
            case .upload: showUploadState()
            case .error: showErrorState()
            case .common: showCommonState()
            }
        }
    }
    
    weak var delegate: UploadMainViewDelegate?
    
    let videoNameTextField = TextField(placeholder: "Enter the name video")
    
    let accessCaptureFailLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Error!\nUnable to access capture devices.", comment: "")
        label.textColor = .black
        label.numberOfLines = 2
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    let uploadIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        return indicator
    }()
    
    let videoIsUploadingLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("video is uploading", comment: "")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    private func addObserver() {
        [UIResponder.keyboardWillShowNotification, UIResponder.keyboardWillHideNotification].forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keybordChange),
                name: $0, 
                object: nil
            )
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
        backgroundColor = .white
        videoNameTextField.delegate = self
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayout()
        backgroundColor = .white
        videoNameTextField.delegate = self
        addObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func initLayoutForCameraView() {
        guard let cameraView = cameraView else { return }
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(cameraView, at: 0)

        NSLayoutConstraint.activate([
            cameraView.leftAnchor.constraint(equalTo: leftAnchor),
            cameraView.topAnchor.constraint(equalTo: topAnchor),
            cameraView.rightAnchor.constraint(equalTo: rightAnchor),
            cameraView.bottomAnchor.constraint(equalTo: videoNameTextField.topAnchor),
        ])
    }
    
    private func initLayout() {
        let views = [videoNameTextField, accessCaptureFailLabel, uploadIndicator, videoIsUploadingLabel]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        let keyboardBottomConstraint = videoNameTextField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        self.keyboardBottomConstraint = keyboardBottomConstraint
        
        NSLayoutConstraint.activate([
            keyboardBottomConstraint,
            videoNameTextField.heightAnchor.constraint(equalToConstant: videoNameTextField.intrinsicContentSize.height + 20),
            videoNameTextField.leftAnchor.constraint(equalTo: leftAnchor),
            videoNameTextField.rightAnchor.constraint(equalTo: rightAnchor),
            
            accessCaptureFailLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessCaptureFailLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            uploadIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            uploadIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            videoIsUploadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            videoIsUploadingLabel.topAnchor.constraint(equalTo: uploadIndicator.bottomAnchor, constant: 20)
        ])
    }
}

extension UploadMainView {
    @objc private func keybordChange(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? NSValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { 
            return
        }

        let keyboardHeight = keyboardFrame.cgRectValue.height - safeAreaInsets.bottom
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            self.keyboardBottomConstraint?.constant = -keyboardHeight
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
        } else {
            self.keyboardBottomConstraint?.constant = 0
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
        }
    }
}

extension UploadMainView {
    private func showUploadState() {
        videoNameTextField.isHidden = true
        uploadIndicator.startAnimating()
        videoIsUploadingLabel.isHidden = false
        accessCaptureFailLabel.isHidden = true
        cameraView?.recordButton.setImage(UIImage(named: "play.icon"), for: .normal)
        cameraView?.isHidden = true
    }
    
    private func showErrorState() {
        accessCaptureFailLabel.isHidden = false
        videoNameTextField.isHidden = true
        uploadIndicator.stopAnimating()
        videoIsUploadingLabel.isHidden = true
        cameraView?.isHidden = true
    }
    
    private func showCommonState() {
        videoNameTextField.isHidden = false
        uploadIndicator.stopAnimating()
        videoIsUploadingLabel.isHidden = true
        accessCaptureFailLabel.isHidden = true
        cameraView?.isHidden = false
    }
}

extension UploadMainView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.videoNameDidUpdate(textField.text ?? "")
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, text.count < 21 else { return false }
        return true
    }
}
