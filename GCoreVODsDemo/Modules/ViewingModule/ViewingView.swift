//
//  ViewingView.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import UIKit

protocol ViewingViewDelegate: AnyObject {
    func reload()
}

final class ViewingView: UIView {
    enum State {
        case empty, proccess, content
    }

    weak var delegate: ViewingViewDelegate?

    var state: State = .proccess {
        didSet {
            switch state {
            case .empty: showEmptyState()
            case .proccess: showProccessState()
            case .content: showContentState()
            }
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "View VODs"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "View VODs that are already loaded."
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    private let indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .grey800
        view.transform = .init(scaleX: 2, y: 2)
        view.hidesWhenStopped = false
        view.startAnimating()
        return view
    }()

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
        button.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        button.backgroundColor = .grey800
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Reload", for: .normal)
        return button
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        let cellNib = UINib(nibName: VODCell.nibName, bundle: nil)
        let footerNib = UINib(nibName: ViewingCollectionFooter.nibName, bundle: nil)
        let footerKind =  UICollectionView.elementKindSectionFooter
        
        view.register(cellNib, forCellWithReuseIdentifier: VODCell.reuseId)
        view.register(footerNib, forSupplementaryViewOfKind: footerKind, withReuseIdentifier: ViewingCollectionFooter.reuseId)
        view.backgroundColor = .white
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayout()
    }
    
    private func showContentState() {
        indicatorView.isHidden = true
        emptyLabel.isHidden = true
        emptyImageView.isHidden = true
        collectionView.isHidden = false
        emptyReloadButton.isHidden = true
    }
    
    private func showEmptyState() {
        indicatorView.isHidden = true
        emptyLabel.isHidden = false
        emptyReloadButton.isHidden = false
        emptyImageView.isHidden = false
        collectionView.isHidden = true
    }
    
    private func showProccessState() {
        indicatorView.isHidden = false
        emptyLabel.isHidden = true
        emptyImageView.isHidden = true
        collectionView.isHidden = true
        emptyReloadButton.isHidden = true
    }
    
    @objc private func reloadButtonTapped() {
        delegate?.reload()
    }
}

private extension ViewingView {
    func initLayout() {
        let views = [
            titleLabel,
            subtitleLabel,
            collectionView, 
            indicatorView,
            emptyImageView, 
            emptyLabel,
            emptyReloadButton
        ]
        
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 0),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyImageView.heightAnchor.constraint(equalToConstant: 100),
            emptyImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16),
            
            emptyReloadButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyReloadButton.widthAnchor.constraint(equalToConstant: ScreenSize.width - 32),
            emptyReloadButton.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 10),
            emptyReloadButton.heightAnchor.constraint(equalToConstant: 48),
            
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
