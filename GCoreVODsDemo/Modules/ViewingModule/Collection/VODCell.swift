//
//  VODCell.swift
//  GCoreVODsDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import UIKit
import Kingfisher

final class VODCell: UICollectionViewCell {
    static let nibName = String(describing: VODCell.self)
    static let reuseId = String(describing: VODCell.self)

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    func setup(name: String, id: String, imageURL: URL?) {
        imageView.layer.cornerRadius = 8
        nameLabel.text = "Name: " + name
        idLabel.text = "ID: " + id        
        imageView.kf.setImage(with: imageURL, placeholder: UIImage.vodPreview)
    }
}
