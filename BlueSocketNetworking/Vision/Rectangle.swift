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
        request.minimumSize = 0.005
        //request.minimumSize = 0.02
        request.minimumAspectRatio = 0
        request.maximumAspectRatio = 50
        
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            self.cgImage = cgImage
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
        //if let results = detectionHandler(results: results) {
            
            self.lastRect1 = results[0]
            self.lastRect2 = results[1]
            
            let observation = groupResults(target1: results[0], target2: results[1])
            
            self.processData(observation: observation)
        //}
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
            
            var heights: [CGFloat] = []
            
            for result in results {
                heights.append(result.bottomLeft.y - result.topLeft.y)
            }
            
            if let maxHeight = heights.max() {
                results = results.filter { (observation) -> Bool in
                    let height = observation.bottomLeft.y - observation.topLeft.y
                    if abs(height / maxHeight) > 0.8 {
                        return true
                    } else {
                        return false
                    }
                }
            }
            
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
            
            if let cg = self.cgImage {
                for left in leftResults {
                    // Crop it
                    var right: VNRectangleObservation? {
                        for right in rightResults {
                            if right.bottomLeft.x > left.bottomRight.x {
                                return right
                            }
                        }
                        return nil
                    }
                    
                    if right == nil { return nil }
                    let grouped = groupResults(target1: left, target2: right!)
                    if ((grouped.width * grouped.height) / ((left.bottomLeft.y - left.topLeft.y) * (left.bottomRight.x - left.bottomLeft.x))) < 3 {
                        if let cropped = cg.cropping(to: CGRect(x: grouped.minX.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .x), y: grouped.minY.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .y), width: grouped.width.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .x), height: grouped.height.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .y))) {
                            
                            // Check it
                            if cropped.getLuminance() {
                                // YAYAYAYAYAYAYAYAYAYAY
                                if isIntersectionAbove(target1: left, target2: right!) {
                                    return [left, right!]
                                }
                            } else {
                                // BADBADBADBADBADBADBAD
                                results.removeAll { (observation2) -> Bool in
                                    if observation2.uuid == left.uuid || observation2.uuid == right!.uuid {
                                        return true
                                    } else {
                                        return false
                                    }
                                }
                            }
                            
                            
                        } else {
                            print("Yo no haveo CGo")
                        }
                    }
                    
                }
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
        //print("Area is \(area)")
        //print(width)
        let viewArea = pixelBufferSize.height * pixelBufferSize.width
        //print("View area is \(viewArea)")
        let percentArea = area / viewArea
        
        DispatchQueue.main.async {
            self.debugView.drawRect(boundingBox: observation, size: self.previewImageView.frame.size)
        }
        
        let scaledArea = (percentArea * 100000).rounded()/1000
        
        let distance = 121.94 * (powf(Float(scaledArea), -0.582))
        
        self.debugValue =
        """
        topLeft of (\(((observation.minX * 100).rounded()/100)), \(((observation.minY * 100).rounded()/100))).
        % Area \((percentArea * 100000).rounded()/1000). Distance of \((distance * 100).rounded()/100)
        Angle: \((angle * 100).rounded()/100) deg.
        """
        
        DispatchQueue.main.async {
            self.debugLabel.text = (
                self.debugValue.appending(" Frames old: \(self.trackingDropped).")
            )
        }
        
        let dateString = Formatter.iso8601.string(from: Date())
        
        server?.setVisionData(data: RectangleData(degreesOfDifference: angle, date: dateString, height: CGFloat(distance)))
        
    }
}

extension CGImage {
    func getLuminance() -> Bool {
        let dataProvider = self.dataProvider?.data as! CFData
        let pixels = CFDataGetBytePtr(dataProvider)
        let length = CFDataGetLength(dataProvider)
        var luminance = 0.0
        var totalLuminace = 0.0
        var i = 0
        while i < length {
            //let r = pixels?[i]
            let g = pixels?[i + 1]
            //let b = pixels?[i + 2]
            
            //luminance calculation gives more weight to r and b for human eyes
            
            luminance += Double(g! / 255)
            totalLuminace += 1.0
            
            i += 4
        }
        
        if (luminance / totalLuminace) > (UserDefaults.standard.double(forKey: DefaultsMap.redMin)) {
            return true
        } else {
            return false
        }
    }/*
     func isDarkImage() -> Bool {
     
     var isDark = false
     
     let imageData = CGImageGetDataProvider(self)?.data
     let pixels = CFDataGetBytePtr(imageData)
     
     var darkPixels: Int = 0
     
     let length = CFDataGetLength(imageData)
     let darkPixelThreshold = Int(Double(self.width) * Double(self.width) * 0.45)
     
     var i = 0
     while i < length {
     let r = pixels?[i]
     let g = pixels?[i + 1]
     let b = pixels?[i + 2]
     
     //luminance calculation gives more weight to r and b for human eyes
     let luminance: Float = 0.299 * r + 0.587 * g + 0.114 * b
     if luminance < 150 {
     darkPixels += 1
     }
     i += 4
     }
     
     if darkPixels >= darkPixelThreshold {
     isDark = true
     }
     
     return isDark
     }*/
    
}
