//
//  Camera.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/14/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import AVFoundation

extension ViewController {
    func setupCamera() throws {
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .back) else {
            
            throw CameraError.captureDeviceNotFound("Built-in wide angle video back camera not found.")
            
        }
        
        let input = try AVCaptureDeviceInput(device: captureDevice)
        self.captureSession = AVCaptureSession()
        guard (captureSession?.canAddInput(input))! else {
            
            throw CameraError.captureSessionFailedtoAddInput("Session failed to add input.")
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.frame = previewView.layer.bounds
        previewView.layer.addSublayer(previewLayer!)
        
        captureSession?.startRunning()
    }
}

enum CameraError: Error {
    case captureDeviceNotFound(String)
    case captureSessionFailedtoAddInput(String)
}
