//
//  Camera.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/14/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import AVFoundation
import UIKit

extension ViewController {
    func setupCamera() throws {
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .back) else {
            
            throw CameraError.captureDeviceNotFound("Built-in wide angle video back camera not found.")
            
        }
        
        self.horizontalFoV = captureDevice.activeFormat.videoFieldOfView
        
        let input = try AVCaptureDeviceInput(device: captureDevice)
        self.captureSession = AVCaptureSession()
        guard (captureSession?.canAddInput(input))! else {
            
            throw CameraError.captureSessionFailedtoAddInput("Session failed to add input.")
        }
        captureSession?.addInput(input)
        
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Sample-Buffer-Delegate"))
        guard (captureSession?.canAddOutput(self.output))! else {
            throw CameraError.captureSessionFailedtoAddOutput("Session failed to add output.")
        }
        captureSession?.addOutput(self.output)
        
        captureSession?.startRunning()
        
        //setupPreview()
    }
    
    func setupPreview() {
        let stream = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        stream.frame = previewView.layer.bounds
        stream.videoGravity = .resizeAspectFill
        stream.masksToBounds = true
        self.previewView.layer.addSublayer(stream)
    }
}

enum CameraError: Error {
    case captureDeviceNotFound(String)
    case captureSessionFailedtoAddInput(String)
    case captureSessionFailedtoAddOutput(String)
}
