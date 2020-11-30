//
//  ViewController.swift
//
//
//  Created by Ali Momeni on 11/5/20.
//

import UIKit
import AVKit
import AVFoundation
import AudioKit
import CoreMotion

class ViewController: UIViewController {
    
    // For video
    var playerLayer: AVPlayer?
    
    // For sensor data
    var motionManager: CMMotionManager!
    var accelY: Double!
    
    
    // For manging recording state
    struct RecorderData {
        var isRecording = false
        var isPlaying = false
    }
    
    // Main class for recording and playback
    var conductor = RecorderConductor()
    
    class RecorderConductor {
                
        // For audio playback
        let engine = AudioEngine()
        let player = AudioPlayer()
        let mixer = Mixer()
        let variSpeed: VariSpeed
        
        
        // For audio recording
        let recorder: NodeRecorder
        let silencer: Fader
        
        var buffer: AVAudioPCMBuffer
        
        var data = RecorderData() {
            didSet {
                if data.isRecording {
                    NodeRecorder.removeTempFiles()
                    do {
                        try recorder.record()
                    } catch let err {
                        print(err)
                    }
                } else {
                    recorder.stop()
                }

                if data.isPlaying {
                    if let file = recorder.audioFile {
                        // added by Ali to auto-stop recording
                        if (recorder.isRecording) {
                            recorder.stop()
                        }
                        
                        buffer = try! AVAudioPCMBuffer(file: file)!
                        player.scheduleBuffer(buffer, at: nil, options: .loops)
                        player.play()
                    }
                } else {
                    player.stop()
                }
            }
        }
        
        
        init() {
            do {
                recorder = try NodeRecorder(node: engine.input!)
            } catch let err {
                fatalError("\(err)")
            }
            
            silencer = Fader(engine.input!, gain: 0)
            
            variSpeed = VariSpeed(player)
            mixer.addInput(silencer)
            mixer.addInput(variSpeed)

            engine.output = mixer
            
            buffer = Cookbook.loadBuffer(filePath: "Sounds/echo_baba3.wav")
            // buffer = AVAudioPCMBuffer(pcmFormat: recorder.audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(recorder.audioFile!.length))!
            
        }
        
        func start() {
            do {
                variSpeed.rate = 1.0
                try engine.start()
            } catch let err {
                print(err)
            }
        }

        func stop() {
            engine.stop()
        }
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        

        

        
        
        conductor.start()
        playVideo("Pictures/echo-jamming")
        // For sensor data
        
        
        motionManager = CMMotionManager()
        
//        var coreMotionManager = CMMotionManager()
//        coreMotionManager.startAccelerometerUpdatesToQueue( self.motionQueue ) { [self] (data, error) } in
//          self.acceleration = data.acceleration
//        }
//
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [self] (data, error) in
                //print(type(of: data))
                accelY = data!.acceleration.y
                
                self.Slider2.setValue(Float((data?.acceleration.y)!), animated: true)

                conductor.variSpeed.rate = Cookbook.scale(Float(accelY), -1, 1, -1, 3)


            }
        }
    }

    private func playVideo(_ filepath: String) {
    
        guard let videoURL = Bundle.main.resourceURL?.appendingPathComponent(filepath) else {
            debugPrint("video not found")
            return
        }
        
        let player = AVPlayer(url: videoURL)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    

    
    @IBOutlet weak var Slider2: UISlider!
    @IBOutlet weak var recordButtonOutlet: UIButton!
    
    
    @IBAction func recordButton(_ sender: UIButton) {
        // sender.setTitleColor(.red, for: .normal)
        conductor.data.isRecording.toggle()
        if (conductor.data.isRecording == true) {
            sender.setTitleColor(.red, for: .normal)
        } else {
            sender.setTitleColor(.darkGray, for: .normal)
        }
    }
    
    @IBAction func RecordButtonUp(_ sender: UIButton) {
        //sender.setTitleColor(.darkGray, for: .normal)
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        print("Play button pressed")
        conductor.data.isPlaying.toggle()
        if (conductor.data.isPlaying == true) {
            sender.setTitleColor(.green, for: .normal)
        } else {
            sender.setTitleColor(.darkGray, for: .normal)
        }
    }

    

}

