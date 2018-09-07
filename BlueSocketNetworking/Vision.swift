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
        //let filled = filtered.floodFill()
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
            let filteredImage = image.colorFilter(target: self.targetControl.selectedSegmentIndex)!
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
        request.maximumObservations = 0
        
        //1.46
        request.minimumAspectRatio = VNAspectRatio(1.88)
        request.maximumAspectRatio = VNAspectRatio(5)
        
        request.minimumConfidence = 0.4
        
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
        
        for result in results {
            if result.confidence > 0.5 {
                let height = result.topLeft.y.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .y) - result.bottomLeft.y.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .y)
                let width = result.topRight.x.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .x) - result.topLeft.x.convertToPixels(pixelBufferSize: pixelBufferSize, axis: .x)
                let aspectRatio = height / width
                print("Detected rect with aspect ratio \(aspectRatio)")
                
                //9.5 width x 6.5 height
                //if aspectRatio >= 0.5 && aspectRatio <= 0.8
                if aspectRatio >= 0.5 && aspectRatio <= 0.8 {
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
     Processes data and finds the angle the detected rectangle is off by.
     
     - Parameter observation: The observation containing the rectangle of which you want to process.
 */
    func processData(observation: VNRectangleObservation) {
        guard let observation = self.lastObservation else { return }
        let centerRectX = (observation.topLeft.x + observation.topRight.x) / 2
        
        let difference = centerRectX - 0.5
        let angle = difference * CGFloat(horizontalFoV!)
        print(angle)
        
        let dateString = Formatter.iso8601.string(from: Date())
        
        let height = (observation.topLeft.y + observation.bottomLeft.y) / 2
        
        DispatchQueue.main.async {
            self.debugLabel.text = "\(((angle * 100).rounded()) / 100) degrees | \(dateString)"
        }
        
        server?.setVisionData(data: RectangleData(degreesOfDifference: angle, date: dateString, height: heightFormula(height: height)))
        /*
        lock(obj: self.currentData as AnyObject) {
            self.currentData = RectangleData(degreesOfDifference: angle, date: dateString, height: heightFormula(height: height))
        }*/
        
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
