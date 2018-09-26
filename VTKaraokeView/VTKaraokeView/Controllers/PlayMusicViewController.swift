//
//  PlayMusicViewController.swift
//  VTKaraokeView
//
//  Created by Tran Viet on 6/21/16.
//  Copyright © 2016 idea. All rights reserved.
//

import UIKit
import AVFoundation

class PlayMusicViewController: UIViewController {
    
    var songURL:NSURL?
    var lyric:VTKaraokeLyric?
    private var timingKeys:Array<CGFloat> = [CGFloat]()
    
    private var audioPlayer:AVAudioPlayer?
    private var playerTimer:Timer?
    
    @IBOutlet private weak var toogleButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var lyricPlayer: VTKaraokeLyricPlayerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lyric = self.lyric, self.lyric?.content != nil {
            timingKeys = Array(lyric.content!.keys).sorted(by: <)
        }
        
        self.lyricPlayer.dataSource = self
        self.lyricPlayer.delegate = self
        
        if let songURL = self.songURL {
            audioPlayer = try! AVAudioPlayer(contentsOf: songURL as URL)
            audioPlayer?.delegate = self
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        audioPlayer?.prepareToPlay()
        lyricPlayer.prepareToPlay()
        
        self.title = self.lyric?.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopAll() {
        playerTimer?.invalidate()
        audioPlayer?.stop()
        lyricPlayer.stop()
    }
    
    @objc func timerStick(timer:Timer) {
        
        if let audioPlayer = self.audioPlayer, audioPlayer.isPlaying {
            let value = audioPlayer.currentTime / audioPlayer.duration
            self.slider.value = Float(value)
        }
        
    }
    
    func startTimer() {
        playerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerStick(timer:)), userInfo: nil, repeats: true)
    }
    
    @IBAction func tooglePlayStop(sender: UIButton) {
        
        if self.toogleButton.tag == 0 {
        
            audioPlayer?.play()
            lyricPlayer.start()
            self.startTimer()
        
        } else {
            
            if !self.lyricPlayer.isPlaying {
            
                self.lyricPlayer.resume()
                audioPlayer?.play()
                self.startTimer()
                self.toogleButton.setTitle("Pause", for: .normal)
            
            } else {
                
                self.lyricPlayer.pause()
                audioPlayer?.pause()
                playerTimer?.invalidate()
                
                self.toogleButton.setTitle("Resume", for: .normal)
                
            }
            
        }
        
    }
    
    @IBAction func sliderDidChange(sender: UISlider) {
        
        guard let audioPlayer = self.audioPlayer else { return }
        
        let songDuration = audioPlayer.duration
        let currentTime = TimeInterval(sender.value) * songDuration
        
        audioPlayer.currentTime = currentTime
        lyricPlayer.setCurrentTime(curTime: currentTime)
    }
    
}



extension PlayMusicViewController: VTLyricPlayerViewDataSource {
    
    func timesForLyricPlayerView(playerView: VTKaraokeLyricPlayerView) -> Array<CGFloat> {
        return timingKeys
    }
    
    func lyricPlayerView(playerView: VTKaraokeLyricPlayerView, atIndex:NSInteger) -> VTKaraokeLyricLabel {
        
        let lyricLabel          = playerView.reuseLyricView()
        lyricLabel.textColor    = UIColor.white
        lyricLabel.fillTextColor = UIColor.blue
        lyricLabel.font         = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        
        let key = timingKeys[atIndex]
        
        lyricLabel.text = self.lyric?.content![key]
        return lyricLabel
    }
    
    func lyricPlayerView(playerView: VTKaraokeLyricPlayerView, allowLyricAnimationAtIndex: NSInteger) -> Bool {
        return true
    }
}

extension PlayMusicViewController: VTLyricPlayerViewDelegate {
    func lyricPlayerViewDidStop(playerView: VTKaraokeLyricPlayerView) {
        playerTimer?.invalidate()
    }
    
    func lyricPlayerViewDidStart(playerView: VTKaraokeLyricPlayerView) {
        self.toogleButton.setTitle("Pause", for: .normal)
        self.toogleButton.tag = 1
    }
}

extension PlayMusicViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.stopAll()
    }
}
