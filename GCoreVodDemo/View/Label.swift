//
//  Label.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 12.08.2022.
//

import UIKit

final class Label: UILabel {
    var insets = UIEdgeInsets(top: 5, left: 16, bottom: 6, right: 16)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + insets.left + insets.right
        let height = superContentSize.height + insets.top + insets.bottom
        return CGSize(width: width, height: height)
    }
}
