//
//  ViewController.swift
//  ios-hsl
//
//  Created by Son Hong Do on 30/09/2021.
//

import UIKit
import StreamingKit
import WebKit
import AVKit

class ViewController: UIViewController, WKScriptMessageHandler, AVPlayerItemMetadataOutputPushDelegate, AVPlayerItemMetadataCollectorPushDelegate  {

    
    
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var greyView: UIView!
    
    @IBOutlet weak var webView: WKWebView!
    
    private let videoPlayer = StreamingVideoPlayer()
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupVideoPlayer()
        
        textField.text = "https://dev-livestream.gviet.vn/manifest/VTV1-PACKAGE/master.m3u8"
        
        let url = URL(string: "https://dev-livestream.gviet.vn/ilp-statics/v1.3.0/ios-interactive.html")
        let request = URLRequest(url: url!)
        webView.load(request)
        webView.configuration.userContentController.add(self, name: "parent")
    }
    
    func onReady() {
        postMessage("onReady", jsonObject: [
            "id": "uuid"
        ])
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let bodyString = message.body as? String {
            let data = Data(bodyString.utf8)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    guard let type = json["type"] as? String else { return }
                    let payload = json["payload"] as? [String: Any] ?? nil
                    print("payload", payload)
                    switch type {
                    case "onReady":
                        onReady()
                    case "onShowOverlay":
                        print("onShowOverlay")
                    case "onHideOverlay":
                        print("onHideOverlay")
                    case "onChangeOverlayRects":
                        print("onChangeOverlayRects")
                    case "onKeyDown":
                        print("onKeyDown")
                    default:
                        print("default")
                    }
                    showAlert(body: bodyString)
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - AVPlayerItemMetadataOutputPushDelegate
    
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        if let item = groups.first?.items.first
        {
            item.value(forKeyPath: #keyPath(AVMetadataItem.value))
            let metadataValue = (item.value(forKeyPath: #keyPath(AVMetadataItem.value))!)
            print("Metadata value: \n \(metadataValue)")
            let metadata = getJSON(fromString: metadataValue as! String)
            postMessage("hlsFragShowingMetadata", jsonObject: [
                "value": metadata
            ])
        } else {
            print("MetaData Error")
        }
    }
    
    // MARK: AVPlayerItemMetadataCollectorPushDelegate
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        if let item = metadataGroups.first?.items.first
        {
            item.value(forKeyPath: #keyPath(AVMetadataItem.value))
            let metadataValue = (item.value(forKeyPath: #keyPath(AVMetadataItem.value))!)
            print("Metadata value: \n \(metadataValue)")
            let metadata = getJSON(fromString: metadataValue as! String)
            postMessage("hlsFragShowingMetadata", jsonObject: [
                "value": metadata
            ])
        } else {
            print("MetaData Error")
        }
    }
    
    
    func showAlert(body: Any) {
        let content = "\(body)"
        let alertController = UIAlertController(title: "Message from Webview", message: content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        let window = UIApplication.shared.windows.first
        window?.rootViewController?.present(alertController, animated: true)
    }
    
    override func observeValue(forKeyPath: String?, of: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if forKeyPath != "timedMetadata" { return }
        let id3Metadata = videoPlayer.handleTimedMetadata(of: of)
        
        let metadata = getJSON(fromString: id3Metadata as! String)
        postMessage("hlsFragShowingMetadata", jsonObject: [
            "value": metadata
        ])
        
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
//        videoPlayer.playerItem.addObserver(self, forKeyPath: "timedMetadata", options: [], context: nil)
        let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
//      instantShow
//        metadataOutput.advanceIntervalForDelegateInvocation = TimeInterval(Int.max)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        
        let metadataCollector = AVPlayerItemMetadataCollector()
        
        metadataCollector.setDelegate(self, queue: DispatchQueue.main)
        
        videoPlayer.playerItem.add(metadataOutput)
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
        
        postMessage("changeButtonClass", jsonObject: data)
    }

    
    func postMessage(_ functionName: String, jsonObject: Any) {
        let jsonString = getString(fromObject: jsonObject)!
        let javascript = "window.\(functionName)('\(jsonString)')"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
    
    func getJSON(fromString jsonString:String) -> Any? {
        if let data = jsonString.removingPercentEncoding?.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with:data , options: .allowFragments) {
            return jsonObject
        }
        return nil
    }
    
    func getString(fromObject jsonObject: Any) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }
    
}



