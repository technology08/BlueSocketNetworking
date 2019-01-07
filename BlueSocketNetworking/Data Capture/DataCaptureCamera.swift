//
//  SettingsCamera.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 10/6/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import AVFoundation
import UIKit

extension DataCaptureViewController {
    /**
     Must be called to enable the camera. Sets up input, output. Orients the video and calculates the horizontal field-of-view angle (stored in self.horizontalFoV).
     */
    func setupCamera() throws {
        //Finds rear camera
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .back) else {
            
            throw CameraError.captureDeviceNotFound("Built-in wide angle video back camera not found.")
            
        }
        
        if captureDevice.isExposureModeSupported(.locked) {
            do {
                try captureDevice.lockForConfiguration()
                //captureDevice.setExposureModeCustom(duration: exposureDuration, iso: minISO) { (time) in
                //    print("Exposure settings have been applied.")
                //}
                //let bias = captureDevice.minExposureTargetBias + 2
                
                let bias = defaults.float(forKey: DefaultsMap.exposure)
                
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
            
            throw CameraError.captureSessionFailedtoAddInput("Session failed to add input.")
        }
        captureSession?.addInput(input)
        
        //Adds delegate as output
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Sample-Buffer-Delegate"))
        guard (captureSession?.canAddOutput(self.output))! else {
            throw CameraError.captureSessionFailedtoAddOutput("Session failed to add output.")
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

extension DataCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        DispatchQueue.main.async {
            if self.filteredSwitch.isOn {
                let (filtered, _) = sampleBuffer.getFilteredImage(
                    redMin: self.defaults.float(forKey: DefaultsMap.redMin),
                    redMax: self.defaults.float(forKey: DefaultsMap.redMax),
                    greenMin: self.defaults.float(forKey: DefaultsMap.greenMin),
                    greenMax: self.defaults.float(forKey: DefaultsMap.greenMax),
                    blueMin:  self.defaults.float(forKey: DefaultsMap.blueMin),
                    blueMax:  self.defaults.float(forKey: DefaultsMap.blueMax),
                    filtered: /*((lastObservation == nil) ? */true /*: false)*/)
                
                let coreimagecontext = CIContext(options: nil)
                let cgimage = coreimagecontext.createCGImage(filtered, from: filtered.extent)
                
                let uiimage = UIImage(cgImage: cgimage!)
                
                self.captureView.image = uiimage
                self.currentImage = uiimage
            } else {
                let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer
                let image = CIImage(cvPixelBuffer: buffer)
                
                let coreimagecontext = CIContext(options: nil)
                let cgimage = coreimagecontext.createCGImage(image, from: image.extent)
                
                let uiimage = UIImage(cgImage: cgimage!)
                self.captureView.image = uiimage
                self.currentImage = uiimage
            }
            
        }
    }
}
