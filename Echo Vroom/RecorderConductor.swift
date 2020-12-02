//
//  RecorderConductor.swift
//  Echo Vroom
//
//  Created by Ali Momeni on 11/30/20.
//

import Foundation

import AVFoundation
import AudioKit
import CoreMotion
import SwiftUI

// For manging recording state
struct RecorderData {
    var isRecording = false
    var isPlaying = false
}

class RecorderConductor: ObservableObject {
            
    // For audio playback
    let engine = AudioEngine()
    let player = AudioPlayer()
    let mixer = Mixer()
    let variSpeed: VariSpeed
    var env: AmplitudeEnvelope
    var plot: NodeOutputPlot
    
    
    // For audio recording
    let recorder: NodeRecorder
    let silencer: Fader
    
    var buffer: AVAudioPCMBuffer
    
    @Published var data = RecorderData() {
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

        env = AmplitudeEnvelope(mixer)
        plot = NodeOutputPlot(env)
        
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
