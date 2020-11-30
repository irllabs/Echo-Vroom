//
//  ViewController.swift
//
//
//  Created by Ali Momeni on 11/5/20.
//

import UIKit
import AVFoundation
import AudioKit

class ViewController: UIViewController {
    
    
    // Find audio files in app resources
    let fm = FileManager.default
    let path = Bundle.main.resourcePath!
    var sounds: [String] = []
    
    // For audio playback
    let engine = AudioEngine()
    let player = AudioPlayer()
    let mixer = Mixer()
    

    
    // var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Build audio file name list
        let fileNameExtension = ".wav"
        if let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath ){
            for file in files {
                if file.hasSuffix(fileNameExtension) {
                    let name = file.prefix(file.count - fileNameExtension.count)
                    sounds.append(String(name))
                }
            }
        }
        
        // Initialize AudioKit pipeline
        mixer.addInput(player)
        engine.output = mixer

        do {
            try engine.start()
        } catch let err {
            print(err)
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        let thisKey = key.keyCode.rawValue
        let thisSound = sounds[thisKey % sounds.count]
        player.stop()
        playSound(soundName: thisSound)
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        let randomSound = sounds.randomElement()
        playSound(soundName: randomSound!)
    }
    
    
    func playSound(soundName: String) {
        
        let url = Bundle.main.url(forResource: soundName, withExtension: "wav")
        
        let randomSoundFile = try! AVAudioFile(forReading: url!)
        player.scheduleFile(randomSoundFile, at: nil)
        player.play()
                
    }
}

