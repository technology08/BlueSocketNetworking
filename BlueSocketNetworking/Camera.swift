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
    /**
     Must be called to enable the camera. Sets up input, output. Orients the video and calculates the horizontal field-of-view angle (stored in self.horizontalFoV).
     */
    func setupCamera() throws {
        //Finds rear camera
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .back) else {
            
            throw CameraError.captureDeviceNotFound("Built-in wide angle video back camera not found.")
            
        }
        
        //Calculates FoV for determining angle
        self.horizontalFoV = captureDevice.activeFormat.videoFieldOfView
        
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
        
        //setupPreview()
    }
    /**
     This configures an AVPreviewLayer for the ViewController's captureSession and adds it to a new layer of the previewView.
     */
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
