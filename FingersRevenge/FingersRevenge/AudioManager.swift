//
//  AudioManager.swift
//  FingersRevenge
//
//  Created by student on 10/17/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//
//  Based on code found here: http://stackoverflow.com/questions/32882737/how-to-play-background-music-with-swift-2-0
//  And here: http://stackoverflow.com/questions/37033036/swift-2-avaudioplayers-to-play-multiple-sounds-at-once
//

import AVFoundation
import SpriteKit

var backgroundMusicPlayer = AVAudioPlayer()

//Play background audio
func playBackgroundMusic(filename: String){
    let url = Bundle.main.url(forResource: filename, withExtension: nil)
    guard let newURL = url else{
        print("Could not find file: \(filename)")
        return
    }
    
    do{
        backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
        backgroundMusicPlayer.volume = 0.70
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    } catch let error as NSError {
        print(error.description)
    }
}
