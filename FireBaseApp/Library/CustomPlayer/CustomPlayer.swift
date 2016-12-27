//
//  CustomPlayer.swift
//  VidMeTest
//
//  Created by Nikola Andriiev on 29.11.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//
//argo - библиотека
import UIKit
import RxSwift
import AVFoundation
import AVKit
import Foundation

class CustomPlayer: UIView {
    @IBOutlet var videoImage: UIImageView!
    @IBOutlet var controlPanelView: UIView!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var player: AVPlayer? = nil
    var playerLayer: AVPlayerLayer? = nil
    
    fileprivate var playerObserver: Any? = nil {
        willSet(newValuer) {
            if let observer = playerObserver {
                self.player?.removeTimeObserver(observer)
            }
        }
    }
    
    var isPlaying: Bool {
        if let status = self.player?.timeControlStatus {
            switch status {
            case .playing: return true
            default: return false
            }
        }
        
        return false
    }
    
    var isControlPanelHiden: Bool = true {
        willSet(newValue) {
            self.bringSubview(toFront: self.controlPanelView)
            if newValue == true {
                self.sliderAnimation(duration: 1, self.frame.maxY)
            } else {
                self.sliderAnimation(duration: 1, self.frame.height - self.controlPanelView.frame.height)
            }
        }
    }
    
    var showSpinner: Bool = false {
        didSet {
            if let spinner = self.spinner {
                self.bringSubview(toFront: spinner)
                spinner.isHidden = !showSpinner
                showSpinner == true ? spinner.startAnimating() : spinner.stopAnimating()
            }
        }
    }
    
    // MARK: Class function
    class func viewOnSuperView(_ view: UIView) -> CustomPlayer? {
        let className = String(describing: CustomPlayer.self)
        if let player = Bundle.main.loadNibNamed(className, owner: nil, options: nil)?[0] as? CustomPlayer {
            player.frame = view.bounds
            view.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin,. flexibleHeight, .flexibleBottomMargin]
            view.addSubview(player)
            
            return player
        }
      
        return nil
    }
    
     // MARK: Class function
    override func awakeFromNib() {
        super.awakeFromNib()
        self.showSpinner = false
        self.sliderAnimation(duration: 0, self.frame.maxY)
    }
    
    public func addPlayer(_ url: URL) {
        DispatchQueue.main.async {
            let player = AVPlayer(url: url)
            self.player = player
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.bounds
            self.playerLayer = playerLayer
            playerLayer.isHidden = true
            self.layer.addSublayer(playerLayer)
            self.isControlPanelHiden = false
            self.showSpinner = true
            if let item = player.currentItem {
                self.observeForItem(item)
            }
        }
    }
    
    public func removePlayer() {
        DispatchQueue.main.async {
            if let item = self.player?.currentItem, let layer = self.playerLayer {
                self.removeObserverFor(item)
                self.stopVideo()
                layer.removeFromSuperlayer()
                self.player = nil; self.playerLayer = nil;
                self.resetInterface()
            }
        }
    }
    
    public func playVideo() {
        if let player = self.player, let playerLayer = self.playerLayer  {
            if player.currentItem?.status == .readyToPlay {
                player.play();
                playerLayer.isHidden = false
                self.videoImage.isHidden = true
            }
        }
    }
    
    public func pauseVideo() {
        if let player = self.player {
            player.pause()
        }
    }
    
    public func stopVideo() {
        if let player = self.player, let layer = self.playerLayer {
            self.pauseVideo()
            player.seek(to: kCMTimeZero)
            layer.isHidden = false
            self.videoImage.isHidden = true
            self.showSpinner = false
            self.playButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    // MARK: @IBAction actions 
        //onMove
    @IBAction func onThumbMove(_ sender: UISlider) {
        if let player = self.player {
            player.pause()
            
            let time = CMTime(seconds: Double(sender.value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player.seek(to: time, completionHandler: { (bool) in
                if bool == true {
                    self.onPlay(self.playButton)
                }
            })
        }
    }
        //onPlay
    @IBAction func onPlay(_ sender: UIButton) {
       if self.isPlaying == false {
            self.playVideo()
            sender.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            self.pauseVideo()
            sender.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    // MARK: Private functions
    
    private func sliderAnimation(duration: TimeInterval , _ verticalPoint: CGFloat) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            guard let playerView = self else {
                return
            }

            let panelFrame = playerView.controlPanelView.frame
            var newFrame = panelFrame
            newFrame.origin = CGPoint(x: 0, y: verticalPoint)
            playerView.controlPanelView.frame = newFrame
        })
    }
    
    private func controls(status: Bool) {
        self.progressSlider.isEnabled = status
        self.playButton.isEnabled = status
    }
    
    private func resetInterface() {
        self.controls(status: false)
        self.progressSlider.value = 0
        self.progressSlider.maximumValue = 0;
        self.currentTimeLabel.text = nil
        self.durationLabel.text = nil
        self.videoImage.isHidden = false
    }
        
    // Action when player ready to play
    private func readyToPlay() {
        if let player = self.player {
            if let duration = player.currentItem?.duration {
                self.progressSlider.maximumValue = Float(duration.seconds)
                self.durationLabel.text = Converter.stringFromTimeInterval(duration.seconds)
                self.showSpinner = false
                self.controls(status: true)
            }
        }
    }
    
    private func removeObserverFor(_ item: AVPlayerItem) {
        self.playerObserver = nil
        item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: item)
    }
    
    private func observeForItem(_ item: AVPlayerItem) {
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
        if let player = self.player {
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            self.playerObserver = self.addTimeObserverForPlayer(player, forTimeInterval: interval)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.videoDidEnd(_ :)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: item)
    }
    
    // Action when video run to end
    @objc private func videoDidEnd(_ notification: NSNotification) {
        self.stopVideo()
    }
    
    // Periodic time observer
    private func addTimeObserverForPlayer(_ player: AVPlayer, forTimeInterval: CMTime) -> Any {
        return player.addPeriodicTimeObserver(forInterval: forTimeInterval,
                                                    queue: DispatchQueue.main,
                                                    using: { (time: CMTime) in
            self.currentTimeLabel.text = Converter.stringFromTimeInterval(time.seconds)
            self.progressSlider.value = Float(time.seconds)
        })
    }
    
    //KVO observation (when playerItem ready to play)
     override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            guard let item = object as? AVPlayerItem else {
                return
            }
           
            switch item.status {
                case .readyToPlay: self.readyToPlay()
                case .unknown: print("Status unknown")
                case .failed: self.controls(status: false)
                              print("[ERROR] Status failed")
            }
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
