//
//  VideoPlayer.swift
//  StreamingKit
//
//  Created by Son Hong Do on 30/09/2021.
//

import AVFoundation
import AVKit


public class StreamingVideoPlayer {
    
    private let playerViewController = AVPlayerViewController()
    
    private let avPlayer = AVPlayer()
    
    public var playerItem: AVPlayerItem!
    
    private lazy var playerView: UIView = {
        let view = playerViewController.view!
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    public init() {
        printTimeStamp()
    }
    
    func printTimeStamp() {
         print("PROGRAM-DATE-TIME: ")
         print(playerItem?.currentDate() ?? "No timeStamp")
     }
    
    // MARK - Public interface
    
    public func add(to view: UIView) {
        view.addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    public func play(url: URL) {
        let asset = AVAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)

        avPlayer.replaceCurrentItem(with: playerItem)
        playerViewController.player = avPlayer
        playerViewController.player?.play()
    }
    
    public func pause() {
        avPlayer.pause()
    }
    
    func getString(fromObject jsonObject: Any) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }
    
    
    public func handleTimedMetadata(of: Any?) -> Any? {
        printTimeStamp()

        let data: AVPlayerItem = of as! AVPlayerItem

        guard let timedMetadata = data.timedMetadata else { return "" }

        for item in timedMetadata {
            if item.key as! String == "TXXX" {
                print("ID3 data: \(item.value!)")
                return item.value
            }
        }
        return nil
    }
    
}
