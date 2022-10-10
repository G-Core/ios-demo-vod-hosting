//
//  VODSmoothCell.swift
//  GCoreVodDemo
//
//  Created by Evgenij Polubin on 11.09.2022.
//

import Foundation
import AsyncDisplayKit

final class VODSmoothCell: ASCellNode {
    var data: VOD
    
    var isShouldPlay = false {
        didSet {
            if isShouldPlay {
                playerNode.play()
            } else {
                playerNode.pause()
            }
        }
    }

    var isPlayerDisplay = false
    var playerNode: ASVideoPlayerNode

    init(data: VOD) {
        self.data = data
        playerNode = ASVideoPlayerNode(url: data.hls!)
        super.init()

        playerNode.delegate = self
        playerNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let hls = data.hls else { return }
            self.playerNode.asset = AVAsset(url: hls)
    
            let dataView = VODDataView()
            dataView.setupData(with: data)
            self.view.addSubview(dataView)
            dataView.frame = self.view.bounds
            self.view.backgroundColor = .black
        }

        addSubnode(playerNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: .zero, child: playerNode)
    }
}

extension VODSmoothCell: ASVideoPlayerNodeDelegate {
    func videoPlayerNodeDidFinishInitialLoading(_ videoPlayer: ASVideoPlayerNode) {
        if isShouldPlay {
            videoPlayer.play()
        }
    }
}
