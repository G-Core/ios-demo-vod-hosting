//
//  VODDataView.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 11.09.2022.
//

import UIKit 

final class VODDataView: UIView {
    private let nameLabel = RoundedLabel()
    private let idLabel = RoundedLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupData(with vod: VOD) {
        nameLabel.text = "Name: \(vod.name)"
        idLabel.text = "ID: \(vod.id)"
    }

    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        [nameLabel, idLabel].forEach {
            $0.numberOfLines = 0
            $0.textColor = .white
            $0.backgroundColor = .darkGray
            $0.font = .systemFont(ofSize: 15)
            $0.textAlignment = .left
            $0.insets.right = 5
            $0.insets.left = 5
        }

        let stackView = UIStackView(arrangedSubviews: [nameLabel, idLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 10

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 30),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60)
        ])
    }
}
