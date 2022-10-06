//
//  ViewingCollectionFooter.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import UIKit

final class ViewingCollectionFooter: UICollectionReusableView {
    static let nibName = String(describing: ViewingCollectionFooter.self)
    static let reuseId = String(describing: ViewingCollectionFooter.self)
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLoading = false
}
