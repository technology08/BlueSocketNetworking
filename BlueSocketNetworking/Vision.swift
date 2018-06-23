//
//  Vision.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 6/16/18.
//  Copyright © 2018 Connor Espenshade. All rights reserved.
//

import AVFoundation
import Vision

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as? CVPixelBuffer else {
            return
        }
        
        self.pixelBufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        
        if lastObservation == nil {
            //First frame, detect and find rectangle
            do {
                try detectRect(pixelBuffer: buffer)
            } catch {
                print(error)
            }
        } else {
            //Continue tracking
            let request = VNTrackRectangleRequest(rectangleObservation: lastObservation!)
            do {
                try sequenceRequestHandler.perform([request], on: buffer)
                let observation = request.results?.first as! VNRectangleObservation
                self.lastObservation = observation
            } catch {
                print(error)
            }
        }
        
    }
    
    
    func detectRect(pixelBuffer: CVPixelBuffer) throws {
        let request = VNDetectRectanglesRequest { (request, error) in
            //Process data from request
            guard error == nil else {
                print(error!)
                return
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        try handler.perform([request])
        
        guard let results = request.results as? [VNRectangleObservation] else {
            return
        }
        
        for result in results {
            
            let height = result.topLeft.y - result.bottomLeft.y
            let width = result.topRight.x - result.topLeft.x
            let aspectRatio = height / width
            //1:5
            if aspectRatio >= 1.8 && aspectRatio <= 2.2 {
                self.lastObservation = result
                break
            }
        }
    
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //Handle dropped frame
    }
    
    func processData() {
        guard let observation = self.lastObservation else { return }
        
    }
}
