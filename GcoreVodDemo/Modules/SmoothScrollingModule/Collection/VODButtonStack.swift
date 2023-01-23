//
//  VODButtonStack.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 21.12.2022.
//

import UIKit

private extension VODButtonStack {
    enum ButtonType: Int, CaseIterable {
        case sound, like, chat, share
    }
}

final class VODButtonStack: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        ButtonType.allCases.forEach { stack.addArrangedSubview(button(for: $0)) }

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let stack = subviews.first else { return nil }
        let convertedPont = stack.convert(point, from: coordinateSpace)
        if stack.point(inside: convertedPont, with: nil) {
            return stack.hitTest(convertedPont, with: event)
        }
        return nil
    }
}

private extension VODButtonStack {
    func button(for type: ButtonType) -> UIView {
        let container = UIView()
        let label = UILabel()
        let button = UIButton()
        let image: UIImage?

        button.tag = type.rawValue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.titleLabel?.text = " "

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white

        container.addSubview(button)
        container.addSubview(label)
        container.translatesAutoresizingMaskIntoConstraints = false

        switch type {
        case .sound:
            label.text = " "
            image = .soundIcon
        case .like:
            label.text = String((100...500).randomElement() ?? 0)
            image = UIImage(named: "like-svgrepo-com")
        case .chat:
            label.text = String((20...60).randomElement() ?? 0)
            image = UIImage(named: "chat-svgrepo-com")
        case .share:
            label.text = String((1...20).randomElement() ?? 0)
            image = UIImage(named: "share-svgrepo-com")
        }

        if #available(iOS 15, *) {
            var config = UIButton.Configuration.plain()
            config.background.image = image
            config.background.imageContentMode = .scaleAspectFit
            config.imageColorTransformer = .monochromeTint
            config.title = " "
            button.configuration = config
        } else {
            button.setTitle(" ", for: .normal)
            button.setBackgroundImage(image, for: .normal)
        }

        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            container.widthAnchor.constraint(equalToConstant: 40),

            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),

            label.topAnchor.constraint(equalTo: button.bottomAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    @objc
    func buttonTapped(_ button: UIButton) {
        switch button.tag {
        case 0:
            if #available(iOS 15, *) {
                let image: UIImage = button.configuration?.background.image == .soundIcon ? .muteIcon : .soundIcon
                button.configuration?.background.image = image
            } else {
                let image: UIImage = button.backgroundImage(for: .normal) == .soundIcon ? .muteIcon : .soundIcon
                button.setBackgroundImage(image, for: .normal)
            }
            return
        default:
            break
        }
    }
}
