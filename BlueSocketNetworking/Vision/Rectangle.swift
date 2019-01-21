//
//  Rectangle.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 1/21/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

import UIKit
import Vision

extension ViewController {
    func rectangleProcessing(filtered: CIImage) {
        if lastRectObservation == nil {
            //First frame, detect and find rectangle
            do {
                try detectRect(ciImage: filtered)
            } catch {
                print("This is where it failed: \(error)")
            }
        } else {
            //Continue tracking
            let request = VNTrackRectangleRequest(rectangleObservation: lastRectObservation!)
            do {
                try sequenceRequestHandler.perform([request], on: filtered)
                let observation = request.results?.first as! VNRectangleObservation
                processData(observation: observation)
                
                self.lastRectObservation = observation
                
                trackingDropped = 0
            } catch {
                print("Tracking failed: \(error)")
                //debugLabel.text = "Tracking failed: \(error)"
                DispatchQueue.main.async {
                    self.debugLabel.text = (
                        self.debugValue.appending(" Frames old: \(self.trackingDropped).")
                    )
                }
                if trackingDropped == Int(defaults.double(forKey: DefaultsMap.frames)) {
                    //Restart detection
                    lastRectObservation = nil
                    trackingDropped = 0
                } else {
                    trackingDropped += 1
                }
            }
        }
    }
    
    
    /**
     Conducts the initial detection of the rectangle for subsequent tracking to be based on.
     - Parameter ciImage: The color-filtered Core Image object to have tracking performed on.
     */
    func detectRect(ciImage: CIImage) throws {
        let request = VNDetectRectanglesRequest(completionHandler: self.detectRectHandler)
        request.maximumObservations = 0
        
        request.minimumConfidence = confidence
        request.minimumSize = 0.02
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try handler.perform([request])
    }
    
    /**
     The completion handler following the initial detection.
     */
    func detectRectHandler(request: VNRequest, error: Error?) {
        guard var results = request.results as? [VNRectangleObservation] else {
            return
        }
        
        // Filter items of too little confidence
        results = results.filter { (observation) -> Bool in
            if observation.confidence > confidence {
                return true
            } else {
                return false
            }
        }
        
        // Sort remaining by confidence
        results = results.sorted { (first, next) -> Bool in
            first.confidence > next.confidence
        }
        
        // Run through sequence of results
        for result in results {
            
            // IMPORTANT: Coordinate space is (0.0, 0.0) in lower left corner, (1.0, 1.0) in upper right.
            
            
            
            let height = result.topLeft.y - result.bottomLeft.y
            //  H2
            //
            //
            //  H1
            let width = result.topRight.x - result.topLeft.x
            //  W1       W2
            //
            //
            //
            
            let aspectRatio = Float(height / width)
            
            print("Detected rect with aspect ratio \(aspectRatio); x: \(result.topLeft.x); y: \(result.topLeft.y); height: \(height); width: \(width)")
            
            // Aspect ratio is HEIGHT / WIDTH
            // 0.35x0.50
            if aspectRatio >= defaults.float(forKey: DefaultsMap.aspectMin) && aspectRatio <= defaults.float(forKey: DefaultsMap.aspectMax) {
                self.lastRectObservation = result
                print("Result points are " + result.topLeft.debugDescription + result.topRight.debugDescription + result.bottomLeft.debugDescription + result.bottomRight.debugDescription)
                print("Rect found with aspect ratio of \(aspectRatio)")
                print("Field of View is \(horizontalFoV!) and buffer size is \(pixelBufferSize.height)x\(pixelBufferSize.width)")
                
                processData(observation: result)
                lastRectObservation = result
                break
            }
        }
        
    }
    
    
    /**
     Processes data and updates `RectangleData` object in `VisionServer`.
     - Finds the difference of the rectangle to the center of the frame.
     - Calculates angle of error from multiplying `difference` by `horizontalFoV` of camera.
     - Updates debug label.
     - Adds time stamp.
     - Configures `RectangleData` object to add to the server.
     
     - Parameter observation: The observation containing the rectangle of which you want to process.
     */
    
    func processData(observation: VNRectangleObservation) {
        // guard let observation = self.lastObservation else { return }
        
        // IMPORTANT: Coordinate space is (0.0, 0.0) in lower left corner, (1.0, 1.0) in upper right.
        
        // Divide Width / 2
        let width = observation.topLeft.x + observation.topRight.x
        // Get the center of the rectangle's width
        let centerRectX = width / 2
        // Difference to center of the view (0.5)
        let difference = 0.5 - centerRectX
        let angle = difference * CGFloat(horizontalFoV!)
        
        let heightAspect = observation.topLeft.y - observation.bottomLeft.y
        let widthAspect = observation.topRight.x - observation.topLeft.x
        
        let rect = CGRect(x: observation.topLeft.x, y: observation.topLeft.y, width: widthAspect, height: heightAspect)
        
        let aspectRatio = Float(heightAspect / widthAspect)
        
        DispatchQueue.main.async {
            self.debugView.drawRect(boundingBox: rect, size: self.previewImageView.frame.size)
        }
        
        self.debugValue =
        """
        topLeft of (\(((observation.topLeft.x * 100).rounded()/100)), \(((observation.topLeft.y * 100).rounded()/100))).
        Aspect of \((aspectRatio * 1000).rounded()/1000).
        Angle off \((angle * 100).rounded()/100) deg.
        """
        
        DispatchQueue.main.async {
            self.debugLabel.text = (
                self.debugValue.appending(" Frames old: \(self.trackingDropped).")
            )
        }
        
        let dateString = Formatter.iso8601.string(from: Date())
        
        let height = (observation.topLeft.y + observation.bottomLeft.y) / 2
        
        server?.setVisionData(data: RectangleData(degreesOfDifference: angle, date: dateString, height: 0))
        
    }
}