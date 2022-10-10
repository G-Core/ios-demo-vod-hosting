//
//  PlayerController.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 09.08.2022.
//

import Foundation
import AVFoundation
import AVKit

final class PlayerController: AVPlayerViewController {
    var hls: URL?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let hls = hls else {
            print("hls url is nil") 
            dismiss(animated: false)
            return
        }
        player = AVPlayer(url: hls)
        player?.play()
    }
}
