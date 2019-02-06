//
//  Vision.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/16/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import AVFoundation
import Vision
import UIKit

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Configures the filter based on user defaults.
        // Also, only filtered if camera not updated in past 5 frames.
        let (filtered, size) = sampleBuffer.getFilteredImage(
            redMin:   defaults.float(forKey: DefaultsMap.redMin  ),
            redMax:   defaults.float(forKey: DefaultsMap.redMax  ),
            greenMin: defaults.float(forKey: DefaultsMap.greenMin),
            greenMax: defaults.float(forKey: DefaultsMap.greenMax),
            blueMin:  defaults.float(forKey: DefaultsMap.blueMin ),
            blueMax:  defaults.float(forKey: DefaultsMap.blueMax ),
            filtered: /*((lastObservation == nil) ? */true /*: false)*/)
        self.pixelBufferSize = size
        
        DispatchQueue.main.async {
            self.previewImageView.image = UIImage(ciImage: filtered)
        }
        
        // i.e. Break the only thing that actually works here in favor of something that ******might****** work
        rectangleProcessing(filtered: filtered)
        //mlProcessing(filtered: filtered)
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //Handle dropped frame
        //print("Dropped")
    }
}
