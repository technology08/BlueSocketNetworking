//
//  SettingsCamera.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 10/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import AVFoundation
import UIKit

extension SettingsViewController {
    /**
     Must be called to enable the camera. Sets up input, output. Orients the video and calculates the horizontal field-of-view angle (stored in self.horizontalFoV).
     */
    func setupCamera() throws {
        //Finds rear camera
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .back) else {
            
            throw Errors.captureDeviceNotFound("Built-in wide angle video back camera not found.")
            
        }
        
        if captureDevice.isExposureModeSupported(.locked) {
            do {
                try captureDevice.lockForConfiguration()
                //captureDevice.setExposureModeCustom(duration: exposureDuration, iso: minISO) { (time) in
                //    print("Exposure settings have been applied.")
                //}
                //let bias = captureDevice.minExposureTargetBias + 2
                
                let bias = exposureSlider.value
                
                captureDevice.setExposureTargetBias(bias) { (time) in
                    print("Configured exposure")
                }
                
            } catch {
                print("Capture Device could not lock for config")
            }
        }
        
        
        //Adds rear camera video as input
        let input = try AVCaptureDeviceInput(device: captureDevice)
        self.captureSession = AVCaptureSession()
        guard (captureSession?.canAddInput(input))! else {
            
            throw Errors.captureSessionFailedtoAddInput("Session failed to add input.")
        }
        captureSession?.addInput(input)
        
        //Adds delegate as output
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Sample-Buffer-Delegate"))
        guard (captureSession?.canAddOutput(self.output))! else {
            throw Errors.captureSessionFailedtoAddOutput("Session failed to add output.")
        }
        captureSession?.addOutput(self.output)
        
        //Orients video
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        captureSession?.startRunning()
        self.device = captureDevice
        //setupPreview()
    }
}

extension SettingsViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        DispatchQueue.main.async {
            let (filtered, _) = sampleBuffer.getFilteredImage(
                redMin:   self.redMinSlider  .value,
                redMax:   self.redMaxSlider  .value,
                greenMin: self.greenMinSlider.value,
                greenMax: self.greenMaxSlider.value,
                blueMin:  self.blueMinSlider .value,
                blueMax:  self.blueMaxSlider .value,
                filtered: true)
            
            self.imageView.image = UIImage(ciImage: filtered)
        }
    }
}
