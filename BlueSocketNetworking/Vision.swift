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
        
        // Configures the filter based on user defaults.
        // Also, only filtered if camera not updated in past 5 frames.
        let (filtered, size) = sampleBuffer.getFilteredImage(
            redMin:   defaults.float(forKey: "redMin"  ),
            redMax:   defaults.float(forKey: "redMax"  ),
            greenMin: defaults.float(forKey: "greenMin"),
            greenMax: defaults.float(forKey: "greenMax"),
            blueMin:  defaults.float(forKey: "blueMin" ),
            blueMax:  defaults.float(forKey: "blueMax" ),
            filtered: ((lastObservation == nil) ? true : false))
        self.pixelBufferSize = size
        
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
                processData(observation: observation)
                self.lastObservation = observation
            } catch {
                print("Tracking failed: \(error)")
                debugLabel.text = "Tracking failed: \(error)"
                if trackingDropped == 5 {
                    //Restart detection
                    lastObservation = nil
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
        let request = VNDetectRectanglesRequest(completionHandler: self.detectHandler)
        request.maximumObservations = 0
        
        request.minimumAspectRatio = VNAspectRatio(1.88)
        request.maximumAspectRatio = VNAspectRatio(5)
 
        request.minimumConfidence = confidence
        
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
        
        // Run through sequence of results
        for result in results {
            /// Probably unnecessary second chance to guarantee `VNRectangleObservation` is greater than user-defined `confidence`
            if result.confidence > confidence {
                let height = result.topLeft.y - result.bottomLeft.y
                let width = result.topRight.x - result.topLeft.x
                
                let aspectRatio = height / width
                
                print("Detected rect with aspect ratio \(aspectRatio); x: \(result.topLeft.x); y: \(result.topLeft.y); height: \(height); width: \(width)")
                
                // Aspect ratio is HEIGHT / WIDTH
                if aspectRatio >= 0.35 && aspectRatio <= 0.50 {
                    self.lastObservation = result
                    print("Result points are " + result.topLeft.debugDescription + result.topRight.debugDescription + result.bottomLeft.debugDescription + result.bottomRight.debugDescription)
                    print("Rect found with aspect ratio of \(aspectRatio)")
                    print("Field of View is \(horizontalFoV!) and buffer size is \(pixelBufferSize.height)x\(pixelBufferSize.width)")
                    
                    processData(observation: result)
                    
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
        guard let observation = self.lastObservation else { return }
        let centerRectX = (observation.topLeft.x + observation.topRight.x) / 2
        
        let difference = centerRectX - 0.5
        let angle = difference * CGFloat(horizontalFoV!)
        print(angle)
        
        DispatchQueue.main.async {
            self.debugLabel.text = ("topLeft of (\(((observation.topLeft.x * 100).rounded()/100)), \(((observation.topLeft.y * 100).rounded()/100)). Angle off \(angle) degrees.")
        }
        
        let dateString = Formatter.iso8601.string(from: Date())
        
        let height = (observation.topLeft.y + observation.bottomLeft.y) / 2
        
        server?.setVisionData(data: RectangleData(degreesOfDifference: angle, date: dateString, height: heightFormula(height: height)))
        
    }
}

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

func heightFormula(height: CGFloat) -> CGFloat {
    let cubed = pow(height, 3)
    let doubled = pow(height, 2)
    
    return (5 * cubed) + (2 * doubled) + (7 * height) + 10
}

/**
 A Swift multithreaded locking function.
 - Parameter obj: The object you wish to lock, or pause read/write actions.
 - Parameter blk: The function in which you update the obj.
 */
func lock(obj: AnyObject, blk:() -> ()) {
    objc_sync_enter(obj)
    blk()
    objc_sync_exit(obj)
}
