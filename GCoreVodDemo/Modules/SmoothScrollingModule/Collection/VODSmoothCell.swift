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
    var playerNode: ASVideoPlayerNode

    var isShouldPlay = false {
        didSet { checkPlayerState(playerNode.playerState) }
    }

    init(data: VOD) {
        self.data = data
        playerNode = ASVideoPlayerNode(url: data.hls!)
        super.init()

        playerNode.placeholderImageURL = data.screenshot
        playerNode.delegate = self
        playerNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let hls = data.hls else { return }
            self.playerNode.asset = AVURLAsset(url: hls)

            let dataView = VODDataView()
            dataView.setupData(with: data)
            dataView.frame = self.view.bounds

            let buttonsView = VODButtonStack(frame: self.view.bounds)

            self.view.addSubview(buttonsView)
            self.view.addSubview(dataView)
            self.view.backgroundColor = .black
        }

        addSubnode(playerNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASInsetLayoutSpec(insets: .zero, child: playerNode)
    }

    private func checkPlayerState(_ state: ASVideoNodePlayerState) {
        switch state {
        case .playbackLikelyToKeepUpButNotPlaying, .paused:
             if isShouldPlay {
                playerNode.play()
            }
        case .playing:
            if !isShouldPlay {
                playerNode.pause()
            }
        default:
            break
        }
    }
}

extension VODSmoothCell: ASVideoPlayerNodeDelegate {
    func videoPlayerNode(_ videoPlayer: ASVideoPlayerNode, willChangeVideoNodeState state: ASVideoNodePlayerState, toVideoNodeState toState: ASVideoNodePlayerState) {
        if toState == .paused && isShouldPlay {
            checkPlayerState(.unknown)
        } else {
            checkPlayerState(toState)
        }
    }

    func videoPlayerNode(_ videoPlayer: ASVideoPlayerNode, didSetCurrentItem currentItem: AVPlayerItem) {
        if #available(iOS 14, *) {
            currentItem.startsOnFirstEligibleVariant = false
        }
        currentItem.preferredMaximumResolution = .init(width: 1920, height: 1080)
        currentItem.preferredPeakBitRate = 6000000
    }
}
