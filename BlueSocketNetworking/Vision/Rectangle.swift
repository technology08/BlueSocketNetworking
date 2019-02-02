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
            do {
                try self.detectRect(ciImage: filtered)
            } catch {
                //print("This is where it failed: \(error)")
            }
        } else {
            //Continue tracking
            if self.rectangle1Tracker == nil {
                self.rectangle1Tracker = VNSequenceRequestHandler()
            }
            
            if self.rectangle2Tracker == nil {
                self.rectangle2Tracker = VNSequenceRequestHandler()
            }
            
            let rect1 = VNTrackRectangleRequest(rectangleObservation: self.lastRect1!)
            rect1.trackingLevel = .fast
            let rect2 = VNTrackRectangleRequest(rectangleObservation: self.lastRect2!)
            rect2.trackingLevel = .fast
            do {
                try self.rectangle1Tracker!.perform([rect1], on: filtered)
                try self.rectangle2Tracker!.perform([rect2], on: filtered)
                
                let results = (rect1.results as? [VNRectangleObservation] ?? []) + (rect2.results as? [VNRectangleObservation] ?? [])
                self.trackRectHandler(results: results)
                self.trackingDropped = 0
            } catch {
                //print("Tracking failed WHY: \(error)")
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
                    self.rectangle1Tracker = nil
                    self.rectangle2Tracker = nil
                    DispatchQueue.main.async {
                        self.debugView.removeRect()
                    }
                } else {
                    self.trackingDropped += 1
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
        request.maximumObservations = 6
        
        request.minimumConfidence = confidence
        request.minimumSize = 0.02
        request.minimumAspectRatio = 0
        request.maximumAspectRatio = 50
        
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            try handler.perform([request])
            //print(request.results!)
        }
    }
    
    /**
     The completion handler following the initial detection.
     */
    func detectRectHandler(request: VNRequest, error: Error?) {
        guard let obsresults = request.results as? [VNRectangleObservation] else {
            return
        }
        
        //let queue = DispatchQueue(label: "detect_it")
        //queue.async {
        if let results = self.detectionHandler(results: obsresults) {
            // Group of two
            
            //print("DETECTED")
            let observation = groupResults(target1: results[0], target2: results[1])
            self.lastRect1 = results[0]
            self.lastRect2 = results[1]
            
            self.processData(observation: observation)
        }
    }
    
    func trackRectHandler(results: [VNRectangleObservation]) {
        if let results = detectionHandler(results: results) {
            self.lastRect1 = results[0]
            self.lastRect2 = results[1]
            
            let observation = groupResults(target1: results[0], target2: results[1])
            
            self.processData(observation: observation)
        }
    }
    
    func detectionHandler(results: [VNRectangleObservation]) -> [VNRectangleObservation]? {
        var results = results
        if results.count < 2 {
            //print("Not enough :(: \(results.count)")
            return nil
        } else {
            // Filter items of too little confidence
            //print("Is enough :)")
            results = results.filter { (observation) -> Bool in
                //print(observation.confidence)
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
            //results = results.sorted { (first, next) -> Bool in
            //    first.confidence > next.confidence
            //}
            
            var leftResults: [VNRectangleObservation] = []
            var rightResults: [VNRectangleObservation] = []
            
            for observation in results {
                if observation.bottomLeft.x < observation.topLeft.x {
                    leftResults.append(observation)
                } else if observation.bottomLeft.x > observation.topLeft.x {
                    rightResults.append(observation)
                }
            }
            
            leftResults = leftResults.sorted { (first, next) -> Bool in
                first.bottomLeft.x < next.topLeft.x
            }
            
            rightResults = rightResults.sorted { (first, next) -> Bool in
                first.bottomLeft.x < next.topLeft.x
            }
            
            guard let leftOne = leftResults.first else { return nil }// Hardcoded for now, please change
            var rightOne: VNRectangleObservation!
            for right in rightResults {
                if right.bottomLeft.x > leftOne.bottomRight.x {
                    rightOne = right
                    break
                }
            }
            
            guard rightOne != nil else { return nil }
            if isIntersectionAbove(target1: leftOne, target2: rightOne) {
                return [leftOne, rightOne]
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
    
    func processData(observation: CGRect) {
        // guard let observation = self.lastObservation else { return }
        
        // IMPORTANT: Coordinate space is (0.0, 0.0) in lower left corner, (1.0, 1.0) in upper right.
        
        let centerRectX = observation.midX
        
        // Difference to center of the view (0.5)
        let difference = 0.5 - centerRectX
        let angle = difference * CGFloat(horizontalFoV!)
        
        let height = observation.height
        let width  = observation.width
        
        let area = (height * pixelBufferSize.height) * (width * pixelBufferSize.width)
        print("Area is \(area)")
        print(width)
        let viewArea = pixelBufferSize.height * pixelBufferSize.width
        print("View area is \(viewArea)")
        let percentArea = area / viewArea
        
        DispatchQueue.main.async {
            self.debugView.drawRect(boundingBox: observation, size: self.previewImageView.frame.size)
        }
        
        self.debugValue =
        """
        topLeft of (\(((observation.minX * 100).rounded()/100)), \(((observation.minY * 100).rounded()/100))).
        Area % of \((percentArea * 100000).rounded()/1000).
        Angle off \((angle * 100).rounded()/100) deg.
        """
        
        DispatchQueue.main.async {
            self.debugLabel.text = (
                self.debugValue.appending(" Frames old: \(self.trackingDropped).")
            )
        }
        
        let dateString = Formatter.iso8601.string(from: Date())
        
        server?.setVisionData(data: RectangleData(degreesOfDifference: angle, date: dateString, height: percentArea))
        
    }
}
