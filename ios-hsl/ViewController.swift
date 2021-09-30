//
//  ViewController.swift
//  ios-hsl
//
//  Created by Son Hong Do on 30/09/2021.
//

import UIKit
import StreamingKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var greyView: UIView!
    
    @IBOutlet weak var webView: WKWebView!
    
    private let videoPlayer = StreamingVideoPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupVideoPlayer()
        
        textField.text = "https://dev-livestream.gviet.vn/manifest/VTV1-PACKAGE/master.m3u8"
                
        let url = URL(string: "https://dev-livestream.gviet.vn/ilp-statics/v1.3.0/ios-interactive.html")
        let request = URLRequest(url: url!)
        webView.load(request)
    

        let doStuffMessageHandler = "doStuffMessageHandler"
//        webView.configuration.userContentController.add(self, name: doStuffMessageHandler)
        
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
    
    @IBAction func sendMessageToWebview() {
        let param1 = "bg-blue-600 text-white p-4"
        let param2 = "bg-red-600 text-white p-4"
        let data: [String: String] = [
            "param1": "\(param1)",
            "param2": "\(param2)"
        ]

        guard let json = try? JSONEncoder().encode(data),
              let jsonString = String(data: json, encoding: .utf8) else {
                return
         }
        
        let javascript = "window.changeButtonClass('\(jsonString)')"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }


}

