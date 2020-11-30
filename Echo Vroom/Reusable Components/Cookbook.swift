import AudioKit
import AVFoundation
import SwiftUI

// Helper functions
class Cookbook {
    static var sourceBuffer: AVAudioPCMBuffer {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        return try! AVAudioPCMBuffer(file: file)!
    }

    static func loadBuffer(filePath: String) -> AVAudioPCMBuffer {
        let url = Bundle.main.resourceURL?.appendingPathComponent(filePath)
        let file = try! AVAudioFile(forReading: url!)
        return try! AVAudioPCMBuffer(file: file)!
    }
    
    static func scale (_ input: Float,_ inputLow: Float,_ inputHigh: Float,_  outputLow: Float,_ outputHigh: Float) -> Float {
        let result = ((input - inputLow) / (inputHigh - inputLow)) * (outputHigh - outputLow) + outputLow
        return result
    }
    
    static func setupDryWetMixPlots(_ plots: NodeOutputPlot...) {
        let colors: [UIColor] = [.red, .blue, .purple]
        for (index, plot) in plots.enumerated() {
            plot.plotType = .rolling
            plot.color = colors[index]
            plot.shouldFill = true
            plot.shouldMirror = true
            plot.setRollingHistoryLength(128)
        }
    }
}
