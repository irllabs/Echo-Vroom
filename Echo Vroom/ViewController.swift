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

struct Constants {
    static let sensorUpdateInterval = 0.1
    static let senstorUpdateFrequency = 1 / sensorUpdateInterval
}

class ViewController: UIViewController {
    

    // For sensor data
    var motionManager: CMMotionManager!
    var accelY: Double!

    
    // Main class for recording and playback
    var conductor = RecorderConductor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        conductor.start()
        
        
        // For sensor data
        
        
        motionManager = CMMotionManager()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = Constants.sensorUpdateInterval
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [self] (data, error) in
                //print(type(of: data))
                accelY = data!.acceleration.y
                
                self.Slider2.setValue(Float((data?.acceleration.y)!), animated: true)

                conductor.variSpeed.rate = Cookbook.scale(Float(accelY), -1, 1, -1, 3)


            }
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

