//
//  VideoEditor.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import Foundation
import AVKit

struct VideoEditor {
    
    func mergeVideos(firstAsset: AVAsset, secondAsset: AVAsset, frameRate: Float) {

        //activityMonitor.startAnimating()
        let mixComposition = AVMutableComposition()
        guard let firstTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            return
        }
        
//        do {
//          try firstTrack.insertTimeRange(
//            CMTimeRangeMake(start: .zero, duration: firstAsset.duration),
//            of: firstAsset.tracks(withMediaType: .video)[0],
//            at: .zero)
//        } catch {
//          print("Failed to load first track")
//          return
//        }

        guard let secondTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            return
        }
            
//        do {
//          try secondTrack.insertTimeRange(
//            CMTimeRangeMake(start: .zero, duration: secondAsset.duration),
//            of: secondAsset.tracks(withMediaType: .video)[0],
//            at: firstAsset.duration)
//        } catch {
//          print("Failed to load second track")
//          return
//        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(
          start: .zero,
          duration: CMTimeAdd(firstAsset.duration, secondAsset.duration))

        let firstInstruction = AVMutableVideoCompositionLayerInstruction(
          assetTrack: firstTrack)
        firstInstruction.setOpacity(0.0, at: firstAsset.duration)
        let secondInstruction = AVMutableVideoCompositionLayerInstruction(
          assetTrack: secondTrack)

        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let comp = AVMutableComposition()
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
//          let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
//          do {
//            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: CMTimeAdd(firstAsset.duration, secondAsset.duration)), of: loadedAudioAsset.tracks(withMediaType: .audio)[0], at: .zero)
//          } catch {
//            print("Failed to load Audio track")
//          }

        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")

        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition

        exporter.exportAsynchronously {
          DispatchQueue.main.async {
              
          }
        }
    }

}
