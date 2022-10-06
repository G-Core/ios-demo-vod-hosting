//
//  VODDataView.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 11.09.2022.
//

import UIKit 

final class VODDataView: UIView {
    private let nameLabel = UILabel()
    private let idLabel = UILabel()

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
        
        [nameLabel, idLabel].forEach {
            $0.widthAnchor.constraint(equalToConstant: $0.intrinsicContentSize.width + 20).isActive = true
            $0.heightAnchor.constraint(equalToConstant: $0.intrinsicContentSize.height + 10).isActive = true
        }
    }

    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        [nameLabel, idLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
            $0.backgroundColor = .darkGray
            $0.font = .systemFont(ofSize: 17)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 15
            $0.textAlignment = .center
        }

        let stackView = UIStackView(arrangedSubviews: [nameLabel, idLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
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
