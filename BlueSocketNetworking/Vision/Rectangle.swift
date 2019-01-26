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
        if lastRect1 == nil && lastRect2 == nil {
            //First frame, detect and find rectangle
            /*let queue = DispatchQueue(label: "por_favor_mantangese_alejado_de_las_puertas")
            queue.async {
                print("First frame")
                
            }*/
            
            do {
                try self.detectRect(ciImage: filtered)
            } catch {
                print("This is where it failed: \(error)")
            }
        } else {
            //Continue tracking
            //let queue = DispatchQueue(label: "Track_the_blooming_thing")
            //queue.async {
                let rect1 = VNTrackRectangleRequest(rectangleObservation: self.lastRect1!)
                let rect2 = VNTrackRectangleRequest(rectangleObservation: self.lastRect2!)
                do {
                    try self.rectangle1Tracker.perform([rect1, rect2], on: filtered)
                    //try self.rectangle2Tracker.perform([rect2], on: filtered)
                    let results = (rect1.results as? [VNRectangleObservation] ?? []) + (rect2.results as? [VNRectangleObservation] ?? [])
                    self.trackRectHandler(results: results)
                    //if detected.confidence > confidence {
                    //processMLData(observation: detected)
                    
                    //self.lastMLObservation = detected
                    
                    self.trackingDropped = 0
                    //} else {
                    //    throw Errors.trackingFailed("Result was \(confidence) for confidence and thus below confidence threshold.")
                    //}
                } catch {
                    print("Tracking failed WHY: \(error)")
                    //debugLabel.text = "Tracking failed: \(error)"
                    DispatchQueue.main.async {
                        self.debugLabel.text = (
                            self.debugValue.appending(" Frames old: \(self.trackingDropped).")
                        )
                    }
                    if self.trackingDropped == Int(self.defaults.double(forKey: DefaultsMap.frames)) {
                        //Restart detection
                        self.lastRect1 = nil
                        self.lastRect2 = nil
                        self.trackingDropped = 0
                        DispatchQueue.main.async {
                            self.debugView.removeRect()
                        }
                    } else {
                        self.trackingDropped += 1
                    }
                }
            //}
            
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
        request.minimumSize = 0.05
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        try handler.perform([request])
    }
    
    /**
     The completion handler following the initial detection.
     */
    func detectRectHandler(request: VNRequest, error: Error?) {
        print("Handler")
        guard let obsresults = request.results as? [VNRectangleObservation] else {
            return
        }
        let queue = DispatchQueue(label: "detect_it")
        queue.async {
            if let results = self.detectionHandler(results: obsresults) {
                // Group of two
                //DispatchQueue.main.async {
                print("DETECTED")
                let observation = groupResults(target1: results[0], target2: results[1])
                self.lastRect1 = results[0]
                self.lastRect2 = results[1]
                //self.lastMLObservation = observation
                self.processData(observation: observation)
                //}
            }
        }
        
    }
    
    func trackRectHandler(results: [VNRectangleObservation]) {
        if let results = detectionHandler(results: results) {
            print("TRACKED")
            self.lastRect1 = results[0]
            self.lastRect2 = results[1]
            let queue = DispatchQueue(label: "processing")
            queue.async {
                let observation = groupResults(target1: results[0], target2: results[1])
                
                //self.lastMLObservation = observation
                self.processData(observation: observation)
            }
            
        }
    }
    
    func detectionHandler(results: [VNRectangleObservation]) -> [VNRectangleObservation]? {
        var results = results
        if results.count < 2 {
            print("Not enough :(")
            return nil
        } else {
            // Filter items of too little confidence
            print("Is enough :)")
            results = results.filter { (observation) -> Bool in
                print(observation.confidence)
                if observation.confidence > confidence {
                    return true
                } else {
                    return false
                }
            }
            
            results = results.filter({ (observation) -> Bool in
                let width = observation.bottomRight.x - observation.bottomLeft.x
                if width > 0.04 {
                    return true
                } else {
                    return false
                }
            })
            
            // Sort remaining by confidence
            results = results.sorted { (first, next) -> Bool in
                first.confidence > next.confidence
            }
            
            // Run through sequence of results
            for (index, result) in results.enumerated() {
                
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
                //if aspectRatio >= defaults.float(forKey: DefaultsMap.aspectMin) && aspectRatio <= defaults.float(forKey: DefaultsMap.aspectMax) {
                
                while (index + 1) < results.count{
                    if isIntersectionAbove(target1: result, target2: results[index+1]) {
                        return [result, results[index+1]]
                    }
                }
                //}
            }
            return nil
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
        
        //let heightAspect = observation.topLeft.y - observation.bottomLeft.y
        //let widthAspect = observation.topRight.x - observation.topLeft.x
        
        let heightAspect = observation.boundingBox.height
        let widthAspect = observation.boundingBox.width
        
        let rect = CGRect(x: observation.topLeft.x, y: observation.topLeft.y, width: widthAspect, height: heightAspect)
        
        let aspectRatio = Float(heightAspect / widthAspect)
        
        DispatchQueue.main.async {
            self.debugView.drawRect(boundingBox: rect, size: self.previewImageView.frame.size)
        }
        
        self.debugValue =
        """
        topLeft of (\(((observation.boundingBox.minX * 100).rounded()/100)), \(((observation.boundingBox.minY * 100).rounded()/100))).
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
