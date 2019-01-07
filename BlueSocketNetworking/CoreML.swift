//
//  CoreML.swift
//  BlueSocketNetworking
//
//  Created by Connor Espenshade on 1/4/19.
//  Copyright © 2019 Connor Espenshade. All rights reserved.
//

import Foundation
import CoreML
import Vision

extension ViewController {
    func detectML(ciImage: CIImage) throws {
        let model = try VNCoreMLModel(for: SteamworksTargetDetector().model)
        
        let objectRecognition = VNCoreMLRequest(model: model, completionHandler: detectMLHandler(request:error:))
        objectRecognition.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([objectRecognition])
        } catch {
            print(error)
        }
    }
    
    /**
     The completion handler following the initial detection.
     */
    func detectMLHandler(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else {
            return
        }
        
        // Run through sequence of results
        for result in results {
            /// Probably unnecessary second chance to guarantee `VNRectangleObservation` is greater than user-defined `confidence`
            if result.confidence > confidence {
                // IMPORTANT: Coordinate space is (0.0, 0.0) in lower left corner, (1.0, 1.0) in upper right.
                
                let boundingBox = result.boundingBox
               
                //let height = boundingBox.height / pixelBufferSize.height
                //  H2
                //
                //
                //  H1
                //let width = boundingBox.width / pixelBufferSize.width
                //  W1       W2
                //
                //
                //
                
                // Aspect ratio is HEIGHT / WIDTH
                // 0.35x0.50
                
                self.lastMLObservation = VNDetectedObjectObservation(boundingBox: result.boundingBox)
                print("Dimensions are " + String(describing: boundingBox.minX) + String(describing: boundingBox.minY) + String(describing: boundingBox.width) + String(describing: boundingBox.height))
                print("Field of View is \(horizontalFoV!) and buffer size is \(pixelBufferSize.height)x\(pixelBufferSize.width)")
                
                processMLData(observation: self.lastMLObservation!)
                break
                
            } else {
                print("Confidence is too low.")
                
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
    
    func processMLData(observation: VNDetectedObjectObservation) {
        // guard let observation = self.lastObservation else { return }
        
        // IMPORTANT: Coordinate space is (0.0, 0.0) in lower left corner, (1.0, 1.0) in upper right.
        
        let boundingBox = observation.boundingBox
        
        // Get the center of the rectangle's width
        let centerRectX = boundingBox.midX / self.pixelBufferSize.width
        
        // Difference to center of the view (0.5)
        let difference = 0.5 - centerRectX
        let angle = difference * CGFloat(horizontalFoV!)
        print(angle)
        
        let heightAspect = boundingBox.height / self.pixelBufferSize.height
        let widthAspect = boundingBox.width / self.pixelBufferSize.width

        
        let aspectRatio = Float(heightAspect / widthAspect)
        
        self.debugValue =
        """
        topLeft of (\(((boundingBox.minX * 100).rounded()/100)), \(((boundingBox.minY * 100).rounded()/100))).
        Aspect of \((aspectRatio * 1000).rounded()/1000).
        Angle off \((angle * 100).rounded()/100) deg.
        """
        
        DispatchQueue.main.async {
            self.debugLabel.text = (
                self.debugValue.appending(" Frames old: \(self.trackingDropped).")
            )
        }
        
        let dateString = Formatter.iso8601.string(from: Date())
        
        let height = heightAspect
        
        server?.setVisionData(data: RectangleData(degreesOfDifference: angle, date: dateString, height: heightFormula(height: height)))
        
    }
    
    func mlProcessing(filtered: CIImage) {
        if lastMLObservation == nil {
            //First frame, detect and find rectangle
            do {
                try detectML(ciImage: filtered)
            } catch {
                print("This is where it failed: \(error)")
            }
        } else {
            //Continue tracking
            let request = VNTrackObjectRequest(detectedObjectObservation: self.lastMLObservation!)
            do {
                try sequenceRequestHandler.perform([request], on: filtered)
                let detected = request.results?.first as! VNDetectedObjectObservation
                processMLData(observation: detected)
                
                self.lastMLObservation = detected
                
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
                    lastMLObservation = nil
                    trackingDropped = 0
                } else {
                    trackingDropped += 1
                }
            }
        }
    }
}
