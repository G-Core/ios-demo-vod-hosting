//
//  RoundedLabel.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 10.10.2022.
//

import UIKit

final class RoundedLabel: Label {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2
    }
}
