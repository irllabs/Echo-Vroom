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
    
    // For pitch shifting
    struct PitchShiftOperationData {
        var baseShift: AUValue = 0
        var range: AUValue = 7
        var speed: AUValue = 3
        var rampDuration: AUValue = 0.1
        var balance: AUValue = 0.5
    }
    
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
        // let mixer = Mixer()
        // let variSpeed: VariSpeed
        let dryWetMixer: DryWetMixer
        let playerPlot: NodeOutputPlot
        let pitchShiftPlot: NodeOutputPlot
        let mixPlot: NodeOutputPlot
        let pitchShift: OperationEffect
        
        
        // For audio recording
        let recorder: NodeRecorder
        let silencer: Fader
        
        var buffer: AVAudioPCMBuffer
        
        var data = RecorderData() {
            didSet {
                if data.isRecording {
                    print("---1")
                    NodeRecorder.removeTempFiles()
                    do {
                        print("---2")
                        try recorder.record()
                    } catch let err {
                        print("---3")
                        print(err)
                    }
                } else {
                    print("---4")
                    recorder.stop()
                }

                if data.isPlaying {
                    print("---7")
                    if let file = recorder.audioFile {
                        // added by Ali to auto-stop recording
                        print("---8")
                        if (recorder.isRecording) {
                            print("---9")
                            recorder.stop()
                         }
                        print("---10")
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
                print("---6")
                recorder = try NodeRecorder(node: engine.input!)
            } catch let err {
                print("---7")
                fatalError("\(err)")
            }
            
            silencer = Fader(engine.input!, gain: 0)
            
//            variSpeed = VariSpeed(player)
//            mixer.addInput(silencer)
//            mixer.addInput(variSpeed)
//            engine.output = mixer
            
            buffer = Cookbook.loadBuffer(filePath: "Sounds/echo_baba3.wav")
            // buffer = AVAudioPCMBuffer(pcmFormat: recorder.audioFile!.processingFormat, frameCapacity: AVAudioFrameCount(recorder.audioFile!.length))!
            
            pitchShift = OperationEffect(player) { player, parameters in
                let sinusoid = Operation.sineWave(frequency: parameters[2])
                let shift = parameters[0] + sinusoid * parameters[1] / 2.0
                return player.pitchShift(semitones: shift)
            }
            pitchShift.parameter1 = 0
            pitchShift.parameter2 = 7
            pitchShift.parameter3 = 3

            dryWetMixer = DryWetMixer(player, pitchShift)
            playerPlot = NodeOutputPlot(player)
            pitchShiftPlot = NodeOutputPlot(pitchShift)
            mixPlot = NodeOutputPlot(dryWetMixer)
            engine.output = dryWetMixer

            Cookbook.setupDryWetMixPlots(playerPlot, pitchShiftPlot, mixPlot)
            
        }
        
        func start() {
            do {
//                variSpeed.rate = 1.0
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

                var shiftAmount = Cookbook.scale(Float(accelY), -1, 1, 0.25, 3)
                conductor.pitchShift.$parameter1.ramp(to: shiftAmount, duration: 0.1)
                //conductor.variSpeed.rate = Cookbook.scale(Float(accelY), -1, 1, -1, 3)


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

