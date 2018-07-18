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
        
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as? CVPixelBuffer else {
            return
        }
        
        let image = CIImage(cvPixelBuffer: buffer)
        guard let filtered = image.colorFilter() else { return }
        
        //Debug Only: Delete
        DispatchQueue.main.async {
            self.previewImageView.image = UIImage(ciImage: filtered)
        }
       
        
        self.pixelBufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        //print("Size is \(self.pixelBufferSize). FOV is \(self.horizontalFoV)")
        if lastObservation == nil {
            //First frame, detect and find rectangle
            do {
                try detectRect(ciImage: filtered)
            } catch {
                print("This is where it failed: \(error)")
            }
        } else {
            //Continue tracking
            let request = VNTrackRectangleRequest(rectangleObservation: lastObservation!)
            do {
                try sequenceRequestHandler.perform([request], on: filtered)
                let observation = request.results?.first as! VNRectangleObservation
                self.lastObservation = observation
            } catch {
                print("Tracking failed: \(error)")
            }
        }
        
    }
    
    
    func detectRect(ciImage: CIImage) throws {
        let request = VNDetectRectanglesRequest(completionHandler: self.detectHandler)
        
        //let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try handler.perform([request])
    }
    
    func detectHandler(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRectangleObservation] else {
            return
        }
        
        /*for result in results {
            if result.confidence > 0.5 {
                DispatchQueue.main.async {
                    self.newDraw(box: result)
                }
            }
            
           
        }*/
        
        
        for result in results {
            if result.confidence > 0.5 {
                let height = result.bottomLeft.y - result.topLeft.y
                let width = result.topRight.x - result.topLeft.x
                let aspectRatio = height / width
                print("Detected rect with aspect ratio \(aspectRatio)")
                
                //Delete
                
                self.lastObservation = result
                
                //1:5
                if aspectRatio >= 0.1 && aspectRatio <= 0.3 {
                    self.lastObservation = result
                    print("Rect found")
                    break
                }
            } else {
                print("Confidence is too low.")
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
