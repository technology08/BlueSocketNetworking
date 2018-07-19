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
        
        let filtered = getFilteredImage(sampleBuffer: sampleBuffer, filtered: true)
        DispatchQueue.main.async {
            self.previewImageView.image = UIImage(ciImage: filtered)
        }
       
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
    
    /**
     Converts CMSampleBuffer produced from delegate to CIImage. Also sets the size of the pixel buffer to self.pixelBufferSize for use in calculations.
     - Parameter sampleBuffer: The sample buffer produced from the captureOutput function to be processed.
     - Parameter filtered: If set to true, the image will be filtered by the colorFilter() func.
     - Returns: CIImage from sample buffer, potentially filtered.
    */
    func getFilteredImage(sampleBuffer: CMSampleBuffer, filtered: Bool) -> CIImage {
        let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer
        
        self.pixelBufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        
        let image = CIImage(cvPixelBuffer: buffer)
        if filtered {
            let filteredImage = image.colorFilter()!
            return filteredImage
        } else {
            return image
        }
    }
    
    /**
     Conducts the initial detection of the rectangle for subsequent tracking to be based on.
     - Parameter ciImage: The color-filtered Core Image object to have tracking performed on.
     */
    func detectRect(ciImage: CIImage) throws {
        let request = VNDetectRectanglesRequest(completionHandler: self.detectHandler)
        
        //let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try handler.perform([request])
    }
    
    /**
     The completion handler following the initial detection.
     */
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
