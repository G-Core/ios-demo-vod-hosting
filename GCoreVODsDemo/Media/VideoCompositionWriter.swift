//
//  VideoCompositionWriter.swift
//  GCoreVODsDemo
//
//  Created by Evgeniy Polyubin on 09.08.2022.
//
import Foundation
import AVFoundation

final class VideoCompositionWriter: NSObject {
    private func merge(recordedVideos: [AVAsset]) -> AVMutableComposition {
        //  create empty composition and empty video and audio tracks
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAudioTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // to correct video orientation
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        
        // add video and audio tracks from each asset to our composition (across compositionTrack)
        var insertTime = CMTime.zero
        for i in recordedVideos.indices {
            let video = recordedVideos[i]
            let duration = video.duration
            let timeRangeVideo = CMTimeRangeMake(start: CMTime.zero, duration: duration)
            let trackVideo = video.tracks(withMediaType: .video)[0]
            let trackAudio = video.tracks(withMediaType: .audio)[0]
            
            try! compositionVideoTrack?.insertTimeRange(timeRangeVideo, of: trackVideo, at: insertTime)
            try! compositionAudioTrack?.insertTimeRange(timeRangeVideo, of: trackAudio, at: insertTime)
            
            insertTime = CMTimeAdd(insertTime, duration)
        }
        return mainComposition
    }
    
    /// Combines all recorded clips into one file
    func mergeVideo(_ documentDirectory: URL, filename: String, clips: [URL], completion: @escaping (Bool, URL?) -> Void) {
        var assets: [AVAsset] = []
        var totalDuration = CMTime.zero
        
        for clip in clips {
            let asset = AVAsset(url: clip)
            assets.append(asset)
            totalDuration = CMTimeAdd(totalDuration, asset.duration)
        }
        
        let mixComposition = merge(recordedVideos: assets)
        
        let url = documentDirectory.appendingPathComponent("link_\(filename)")
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                if exporter.status == .completed {
                    completion(true, exporter.outputURL)
                } else {
                    completion(false, nil)
                }
            }
        }
    }
}
