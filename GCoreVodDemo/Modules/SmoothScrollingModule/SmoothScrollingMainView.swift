//
//  SmoothScrollingMainView.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 15.08.2022.
//

import UIKit
import AVKit
import AsyncDisplayKit

protocol SmoothScrollingMainViewDelegate: AnyObject {
   func reload()
}

final class SmoothScrollingMainView: UIView {
    enum State {
        case proccess, empty, content
    }
    
    weak var delegate: SmoothScrollingMainViewDelegate?
    
    var state: State = .proccess {
        didSet {
            switch state {
            case .empty: showEmptyState()
            case .proccess: showProccessState()
            case .content: showContentState()
            }
        }
    }

    lazy var tableView: ASTableNode = {
        let table = ASTableNode(style: .plain)
        table.view.isPagingEnabled = true
        table.view.separatorColor = .clear
        table.view.backgroundColor = .black
        return table
    }()
    
    private let indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .grey800
        view.transform = .init(scaleX: 2, y: 2)
        view.hidesWhenStopped = false
        view.startAnimating()
        return view
    }()
    
    private let emptyView = EmptyStateView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        emptyView.delegate = self
        initLayout()
    }
    
    private func showContentState() {
        indicatorView.isHidden = true
        emptyView.isHidden = true
        tableView.isHidden = false
    }
    
    private func showEmptyState() {
        indicatorView.isHidden = true
        emptyView.isHidden = false
        tableView.isHidden = true
    }
    
    private func showProccessState() {
        indicatorView.isHidden = false
        emptyView.isHidden = true
        tableView.isHidden = true
    }
}

extension SmoothScrollingMainView {
    func initLayout() {
        [tableView.view, indicatorView, emptyView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            tableView.view.topAnchor.constraint(equalTo: topAnchor),
            tableView.view.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.view.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.view.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            emptyView.leftAnchor.constraint(equalTo: leftAnchor),
            emptyView.rightAnchor.constraint(equalTo: rightAnchor),

            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension SmoothScrollingMainView: StateViewDelegate {
    func tapReloadButton() {
        delegate?.reload()
    }
}
