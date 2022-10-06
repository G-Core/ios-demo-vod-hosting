//
//  EmptyStateView.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 23.08.2022.
//

import UIKit

protocol StateViewDelegate: AnyObject {
    func tapReloadButton()
}

final class EmptyStateView: UIView {
    weak var delegate: StateViewDelegate?

    private let emptyImageView: UIImageView = {
        let view = UIImageView()
        view.image = .emptyIcon
        view.backgroundColor = .clear
        return view
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "There are no VODs to watch yet."
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    private let emptyReloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .grey800
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Reload", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .white
        emptyReloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)

        [emptyImageView, emptyLabel, emptyReloadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            emptyImageView.heightAnchor.constraint(equalToConstant: 100),
            emptyImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16),
            
            emptyReloadButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyReloadButton.widthAnchor.constraint(equalToConstant: ScreenSize.width - 32),
            emptyReloadButton.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 10),
            emptyReloadButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func reloadButtonTapped() {
        delegate?.tapReloadButton()
    }
}
