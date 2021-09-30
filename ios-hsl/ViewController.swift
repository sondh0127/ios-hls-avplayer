//
//  ViewController.swift
//  ios-hsl
//
//  Created by Son Hong Do on 30/09/2021.
//

import UIKit
import StreamingKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var greyView: UIView!
    
    private let videoPlayer = StreamingVideoPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupVideoPlayer()
        
        textField.text = "https://dev-livestream.gviet.vn/manifest/VTV1-PACKAGE/master.m3u8"
        
    }
    
    override func observeValue(forKeyPath: String?, of: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if forKeyPath != "timedMetadata" { return }
            videoPlayer.handleTimedMetadata(of: of)
        }
    
    func setupVideoPlayer() {
        videoPlayer.add(to: greyView)
    }
    
    @IBAction func playButtonTapped() {
        
        guard let text = textField.text,
                let url = URL(string: text) else {
            print("Error parsing URL")
            return }
        videoPlayer.play(url: url)
        
        print("play")
        videoPlayer.playerItem.addObserver(self, forKeyPath: "timedMetadata", options: [], context: nil)
    }
    
    @IBAction func pauseButtonTapped() {
        videoPlayer.pause()
    }
    
    @IBAction func clearButtonTapped() {
        textField.text = nil
        videoPlayer.pause()
    }


}

